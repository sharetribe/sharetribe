require "spec_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#add_links" do
    it "adds links to www. fragments" do
      expect(helper.add_links("Link to www.site.com")).to eq("Link to <a class=\"truncated-link\" href=\"http://www.site.com\">www.site.com</a>")
    end

    it "adds links to http:// fragments" do
      expect(helper.add_links("Link to http://site.com")).to eq("Link to <a class=\"truncated-link\" href=\"http://site.com\">http://site.com</a>")
    end

    it "adds links to https:// fragments" do
      expect(helper.add_links("Link to https://site.com/path")).to eq("Link to <a class=\"truncated-link\" href=\"https://site.com/path\">https://site.com/path</a>")
    end

    it "does not add links to site.com" do
      expect(helper.add_links("Link to site.com")).to eq("Link to site.com")
    end

    it "preserves wrapped punctuation" do
      expect(helper.add_links("Visit us at www.site.com.")).to eq("Visit us at <a class=\"truncated-link\" href=\"http://www.site.com\">www.site.com</a>.")
      expect(helper.add_links("(read more on http://site.com)")).to eq("(read more on <a class=\"truncated-link\" href=\"http://site.com\">http://site.com</a>)")
    end
  end
end
