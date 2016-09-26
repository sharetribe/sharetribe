require 'spec_helper'

describe Result do
  let(:success) { Result::Success.new(1) }
  let(:success_nil) { Result::Success.new(nil) }
  let(:error) { Result::Error.new("some message", {some_data: true}) }


  def expect_success(result, expected_data)
    expect(result).to be_a(Result::Success)
    expect(result[:data]).to be_eql(expected_data)
  end

  def expect_error(result, expected_error_msg, expected_error_data=nil)
    expect(result).to be_a(Result::Error)
    expect(result[:error_msg]).to be_eql(expected_error_msg)
    expect(result[:data]).to be_eql(expected_error_data)
  end

  describe "#all" do
    it "returns Success and array as a data" do
      first_result = nil
      second_result = nil
      third_result = nil

      final_result = Result.all(
        ->(*args) {
          first_result = args
          Result::Success.new(1)
        },
        ->(*args) {
          second_result = args
          Result::Success.new(2)
        },
        ->(*args) {
          third_result = args
          Result::Success.new(3)
        })

      expect(first_result).to eq([])
      expect(second_result).to eq([1])
      expect(third_result).to eq([1, 2])
      expect_success(final_result, [1, 2, 3])
    end

    it "returns the first Error" do
      first_result = nil
      second_result = nil
      third_result = nil

      final_result = Result.all(
        ->(*args) {
          first_result = args
          Result::Success.new(1)
        },
        ->(*args) {
          second_result = args
          Result::Error.new("error 1")
        },
        ->(*args) {
          third_result = args
          Result::Success.new("error 2")
        })

      expect(first_result).to eq([])
      expect(second_result).to eq([1])
      expect(third_result).to eq(nil)
      expect_error(final_result, "error 1")
    end

    it "throws error if lambda results something else than result" do
      expect { Result.all(->() { success })}.not_to raise_error
      expect { Result.all(->() { error })}.not_to raise_error
      expect { Result.all(->() { "a string" })}.to raise_error(ArgumentError, "Lambda must return Result")
    end
  end

  describe Result::Success do

    describe "#and_then" do

      it "returns new Success result" do
        expect_success(success.and_then { |v| Result::Success.new(v + 1) }, 2)
      end

      it "returns new Error result" do
        expect_error(success.and_then { |v| Result::Error.new(:error, v - 1) }, :error, 0)
      end

      it "raises if Result is not returned" do
        expect { success.and_then { |v| v + 1 } }.to raise_error("Block must return Result")
      end
    end

    describe "#rescue" do

      it "returns the original success when rescued" do
        expect_success(success.rescue { Result::Success.new(nil) }, 1)
      end

      it "returns the original success" do
        expect_success(success.rescue { Result::Error.new(nil) }, 1)
      end
    end

    describe "#maybe" do

      it "returns Some(value)" do
        expect(success.maybe.or_else(0)).to eql(1)
      end

      it "returns None if result data is a non-value" do
        expect(success_nil.maybe.or_else(0)).to eql(0)
      end
    end
  end

  describe "#on_success" do
    before(:each) {
      @executed = false
    }

    it "executes on success" do
      success.on_success { |data|
        @executed = true
        expect(data).to eq 1
      }

      expect(@executed).to eq true
    end

    it "does not execute on error" do
      error.on_success { |data|
        @executed = true
      }
      expect(@executed).to eq false
    end

    it "allows chaining by returning self" do
      expect(success.on_success {}).to be_a Result::Success
      expect(error.on_success {}).to be_a Result::Error
    end
  end

  describe "#on_error" do
    before(:each) {
      @executed = false
    }

    it "executes on error" do
      error.on_error { |error_msg, data|
        @executed = true
        expect(error_msg).to eq "some message"
        expect(data).to eq({some_data: true})
      }

      expect(@executed).to eq true
    end

    it "does not execute on success" do
      success.on_error { |error_msg, data|
        @executed = true
      }
      expect(@executed).to eq false
    end

    it "allows chaining by returning self" do
      expect(success.on_error {}).to be_a Result::Success
      expect(error.on_error {}).to be_a Result::Error
    end
  end

  describe Result::Error do

    let(:error) { Result::Error.new(:error, 1) }

    describe "#new" do

      it "puts given error_msg and data in place" do
        e = Result::Error.new("msg", {foo: :bar})
        expect(e.error_msg).to eq("msg")
        expect(e.data).to eq({foo: :bar})
      end

      it "when error_msg is a StandardError extract message and sets exception as data" do
        ex = StandardError.new("error message")
        e = Result::Error.new(ex)

        expect(e.error_msg).to eq(ex.message)
        expect(e.data).to eq(ex)
      end
    end

    describe "#and_then" do

      it "is a no-op" do
        expect_error(error.and_then { |v| Result::Success(v + 1) }, :error, 1)
      end
    end

    describe "#rescue" do

      it "rescues an error into a success" do
        msg = "ok"
        expect_success(error.rescue { Result::Success.new(msg) }, msg)
      end

      it "rescues an error into the same error" do
        original_msg = error[:error_msg]
        original_data = error[:data]
        expect_error(error.rescue { |m, d| Result::Error.new(m, d) }, original_msg, original_data)
      end

      it "rescues an error into another error" do
        new_msg = "new error message"
        original_msg = error[:error_msg]
        original_data = error[:data]
        expect_error(
          error.rescue { |m, d|
            Result::Error.new(new_msg, { msg: m, data: d })
          },
          new_msg,
          { msg: original_msg, data: original_data })
      end
    end

    describe "#maybe" do

      it "returns None" do
        expect(error.maybe.or_else(0)).to eql(0)
      end
    end
  end
end
