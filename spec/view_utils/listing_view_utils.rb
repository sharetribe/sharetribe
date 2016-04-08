require "spec_helper"

describe ListingViewUtils do

  VALID_URLS = [
      'http://www.youtube.com/watch?v=UffchBUUIoI',
      'http://www.youtube.com/watch?v=UffchBUUIoI&feature=channel',
      'http://www.youtube.com/watch?v=hpokm-pMaHg&playnext_from=TL&videos=osPknwzXEas&feature=sub',
      'http://www.youtube.com/watch?v=BM7FWtADD0s&feature=youtube_gdata_player',
      'https://www.youtube.com/watch?v=Kk8Mclb_LSw&feature=youtu.be',
      'http://www.youtube.com/embed/UffchBUUIoI?rel=0',
      'http://youtube.com/?v=BM7FWtADD0s&feature=youtube_gdata_player',
      'http://youtube.com/watch?v=BM7FWtADD0s&feature=youtube_gdata_player',
      'http://youtube.com/v/BM7FWtADD0s?feature=youtube_gdata_player',
      'http://youtu.be/BM7FWtADD0s?feature=youtube_gdata_player',
      'https://youtu.be/Kk8Mclb_LSw',
      'http://youtu.be/hpokm-pMaHg'
  ]

  describe "#youtube_video_id" do
    it "returns nil for parameter that isn't string or doesn't contain youtube_video_id" do
      expect(ListingViewUtils.youtube_video_id(nil)).to eq(nil)
      expect(ListingViewUtils.youtube_video_id("youtube.com")).to eq(nil)
      expect(ListingViewUtils.youtube_video_id("example.com/?v=UffchBUUIoI")).to eq(nil)
      expect(ListingViewUtils.youtube_video_id("example.com/embed/UffchBUUIoI")).to eq(nil)
      expect(ListingViewUtils.youtube_video_id("example.com/v/BM7FWtADD0s")).to eq(nil)
    end

    it "returns an id if youtube link is given" do
      VALID_RETURN_IDS = [
        'UffchBUUIoI',
        'hpokm-pMaHg',
        'Kk8Mclb_LSw',
        'BM7FWtADD0s'
      ]

      VALID_URLS.each {|url|
        expect(VALID_RETURN_IDS).to include ListingViewUtils.youtube_video_id(url)
      }
    end
  end

  describe "#youtube_video_ids" do
    it "does not return youtube ids if there ain't any" do
      expect(ListingViewUtils.youtube_video_ids(nil)).to be_empty

      lorem = "Lorem ipsum consectetur adepisci velit"
      expect(ListingViewUtils.youtube_video_ids(lorem)).to be_empty

      httpasdf = "Lorem ipsum httpasdf consectetur adepisci velit"
      expect(ListingViewUtils.youtube_video_ids(httpasdf)).to be_empty

      vimeo = "Lorem ipsum http://vimeo.com?v=BM7FWtADD0s consectetur adepisci velit"
      expect(ListingViewUtils.youtube_video_ids(vimeo)).to be_empty
    end

    it "returns youtube ids when there are valid urls among texts" do
      expected_ids = [
        "UffchBUUIoI",
        "UffchBUUIoI",
        "hpokm-pMaHg",
        "BM7FWtADD0s",
        "Kk8Mclb_LSw",
        "UffchBUUIoI",
        "BM7FWtADD0s",
        "BM7FWtADD0s",
        "BM7FWtADD0s",
        "BM7FWtADD0s",
        "Kk8Mclb_LSw",
        "hpokm-pMaHg"]

      expect(ListingViewUtils.youtube_video_ids(VALID_URLS.join(' '))).to eq(expected_ids)
    end
  end
end
