function translate(translations) {
  return function translateKey(translationKey) {
    return translations[translationKey];
  };
}

export { translate };
