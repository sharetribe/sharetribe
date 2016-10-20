module.exports = {
  extends: 'stylelint-config-standard',
  rules: {
    // stylelint-config-standard overrides
    'shorthand-property-no-redundant-values': null,
    'selector-pseudo-class-no-unknown': [true, { ignorePseudoClasses: ['global'] }],
    'property-no-unknown': [true, { ignoreProperties: ['composes'] }],

    // Single quotes everywhere
    'font-family-name-quotes': 'always-where-recommended',
    'function-url-quotes': 'always',
    'string-quotes': 'single',

    // Disallow using vendor prefixes to let Autoprefixer handle them
    'at-rule-no-vendor-prefix': true,
    'media-feature-name-no-vendor-prefix': true,
    'property-no-vendor-prefix': true,
    'selector-no-vendor-prefix': true,
    'value-no-vendor-prefix': true,

    // Warn about TODO comments
    'comment-word-blacklist': [['/TODO\\b/', '/FIXME\\b/', '/XXX\\b/'], {
      severity: 'warning',
    }],

    'selector-no-id': true,
    'selector-no-qualifying-type': [true, { ignore: ['attribute'] }],

    // Allow only camelCased class selectors that can be used without
    // quoting within JavaScript with CSS modules
    'selector-class-pattern': /^[a-zA-Z_]+$/,

    'custom-property-no-outside-root': true,
    'selector-root-no-composition': true,
    'no-browser-hacks': true,
  },
};
