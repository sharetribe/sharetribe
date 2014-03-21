describe('translations', function () {
  it('#t', function () {
    // Notice, ST.translations is "singleton"
    ST.loadTranslations({
      "test.key": "Test key",
      "test.key.with.interpolation": "Test key, value 1: ${value_1}, value 2: ${value_2}"
    });

    expect(ST.t("test.key")).to.eql("Test key");
    expect(ST.t("test.key.with.interpolation", {value_1: "foo", value_2: "bar"})).to.eql("Test key, value 1: foo, value 2: bar");
  });
});