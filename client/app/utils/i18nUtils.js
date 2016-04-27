function translate(translations) {
  return function(translationKey) {
    return translations[translationKey];
  }
}

export { translate };
