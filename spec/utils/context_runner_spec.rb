# Make test faster by not requiring Rails environment (spec_helper).
# In that case, we need to manually require the file we need.

require_relative '../../app/utils/context_runner'

describe ContextRunner do

  module EnterMW # :nodoc:
    def enter(ctx)
      enters = ctx[:enters] || []
      enters << name
      ctx[:enters] = enters
      ctx
    end
  end

  module LeaveMW # :nodoc:
    def leave(ctx)
      leaves = ctx[:leaves] || []
      leaves << name
      ctx[:leaves] = leaves
      ctx
    end
  end

  module ErrorRaiseMW # :nodoc:
    def error(ctx)
      errors = ctx[:errors] || []
      errors << name
      ctx[:errors] = errors
      ctx
    end
  end

  module ErrorResolveMW # :nodoc:
    def error(ctx)
      errors = ctx[:errors] || []
      errors << name
      ctx[:errors] = errors
      ctx[:error] = nil
      ctx
    end
  end

  module EnterRaiseMW # :nodoc:
    def enter(ctx)
      raise StandardError.new("middleware enter failed")
    end
  end

  module LeaveRaiseMW # :nodoc
    def leave(ctx)
      raise StandardError.new("middleware leave failed")
    end
  end

  class TestMiddlewareEL # :nodoc:
    include EnterMW
    include LeaveMW

    attr_reader :name
    def initialize(name)
      @name = name
    end
  end

  class TestMiddlewareE # :nodoc:
    include EnterMW

    attr_reader :name
    def initialize(name)
      @name = name
    end
  end

  class TestMiddlewareL # :nodoc:
    include LeaveMW

    attr_reader :name
    def initialize(name)
      @name = name
    end
  end

  class TestMiddlewareELERaise
    include EnterMW
    include LeaveMW
    include ErrorRaiseMW

    attr_reader :name
    def initialize(name)
      @name = name
    end
  end

  class TestMiddlewareRaise
    include EnterRaiseMW
  end

  class TestMiddlewareELEResolve
    include EnterMW
    include LeaveMW
    include ErrorResolveMW

    attr_reader :name
    def initialize(name)
      @name = name
    end
  end

  class TestMiddlewareELRaise
    include EnterMW
    include LeaveRaiseMW

    attr_reader :name
    def initialize(name)
      @name = name
    end
  end


  it 'exists' do
    expect(ContextRunner).not_to be nil
  end

  it 'executes enter and leave phases of middleware' do
    mw = TestMiddlewareEL.new(:one)
    runner = ContextRunner.new([mw])
    ctx = runner.execute(nil)

    expect(ctx[:enters]).to eql [:one]
    expect(ctx[:leaves]).to eql [:one]
  end

  it 'executes enters in given orders and leaves in reverse' do
    mw1 = TestMiddlewareEL.new(:one)
    mw2 = TestMiddlewareEL.new(:two)
    mw3 = TestMiddlewareEL.new(:three)
    runner = ContextRunner.new([mw1, mw2, mw3])
    ctx = runner.execute(nil)

    expect(ctx[:enters]).to eql [:one, :two, :three]
    expect(ctx[:leaves]).to eql [:three, :two, :one]
  end

  it 'calls enter and leave only on middleware that define them' do
    mw1 = TestMiddlewareE.new(:one)
    mw2 = TestMiddlewareEL.new(:two)
    mw3 = TestMiddlewareL.new(:three)
    runner = ContextRunner.new([mw1, mw2, mw3])
    ctx = runner.execute(nil)

    expect(ctx[:enters]).to eql [:one, :two]
    expect(ctx[:leaves]).to eql [:three, :two]
  end

  it 'calls error on all middlewares in stack' do
    mw1 = TestMiddlewareELERaise.new(:one)
    mw2 = TestMiddlewareELERaise.new(:two)
    mw3 = TestMiddlewareRaise.new
    runner = ContextRunner.new([mw1, mw2, mw3])
    ctx = runner.execute(nil)

    expect(ctx[:enters]).to eql [:one, :two]
    expect(ctx[:leaves]).to eql nil
    expect(ctx[:errors]).to eql [:two, :one]
  end

  it 'middleware can resolve an error which leads to remaining leaves being called' do
    mw1 = TestMiddlewareEL.new(:one)
    mw2 = TestMiddlewareELEResolve.new(:two)
    mw3 = TestMiddlewareRaise.new
    runner = ContextRunner.new([mw1, mw2, mw3])
    ctx = runner.execute(nil)

    expect(ctx[:enters]).to eql [:one, :two]
    expect(ctx[:leaves]).to eql [:one]
    expect(ctx[:errors]).to eql [:two]
  end

  it 'leave raising trigger the error flow' do
    mw1 = TestMiddlewareELERaise.new(:one)
    mw2 = TestMiddlewareELRaise.new(:two)
    mw3 = TestMiddlewareEL.new(:three)
    runner = ContextRunner.new([mw1, mw2, mw3])
    ctx = runner.execute(nil)

    expect(ctx[:enters]).to eql [:one, :two, :three]
    expect(ctx[:leaves]).to eql [:three]
    expect(ctx[:errors]).to eql [:one]
  end
end
