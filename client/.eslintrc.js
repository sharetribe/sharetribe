module.exports = {

  // This makes sure ESLint doesn't traverse the directory tree
  // upwards to find more .eslintrc.* files outside the project
  // directory that might affect the linting results.
  root: true,

  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
  ],
  parser: 'babel-eslint',
  parserOptions: {
    ecmaVersion: 6,
    sourceType: 'module',
    impliedStrict: true,
    experimentalObjectRestSpread: true,
  },
  plugins: [
    'react',
    'babel',
  ],
  env: {
    browser: true,
    es6: true,
    mocha: true,
    node: true
  },
  globals: {
    // `process` global is added by Webpack plugin.
    // Tell the existence of `process` to ESLint
    process: false,
    storybookFacade: false,
  },
  rules: {
    // See http://eslint.org/docs/rules/ for documentation for
    // specific rules and their options.
    //
    // 0 = off
    // 1 = warn
    // 2 = error

    // ESLint built-in 'Possible Errors' rules
    'comma-dangle': [2, 'always-multiline'],
    'no-unsafe-finally': 2,


    // ESLint built-in 'Best Practices' rules
    'array-callback-return': 2,
    'consistent-return': 2,
    curly: [2, 'all'],
    'default-case': 2,
    'dot-location': [2, 'property'],
    'dot-notation': 2,
    eqeqeq: [2, 'smart'],
    'guard-for-in': 2,
    'no-alert': 2,
    'no-caller': 2,
    'no-case-declarations': 2,
    'no-div-regex': 2,
    'no-empty-function': 2,
    'no-empty-pattern': 2,
    'no-eval': 2,
    'no-extend-native': 2,
    'no-extra-bind': 2,
    'no-extra-label': 2,
    'no-fallthrough': 2,
    'no-floating-decimal': 2,
    'no-implicit-coercion': [2, {
      allow: ['!!'],
    }],
    'no-implicit-globals': 2,
    'no-implied-eval': 2,
    'no-invalid-this': 2,
    'no-iterator': 2,
    'no-labels': 2,
    'no-lone-blocks': 2,
    'no-loop-func': 2,
    'no-magic-numbers': [1, {
      ignore: [0, 1, -1],
      ignoreArrayIndexes: true,
      enforceConst: true
    }],
    'no-multi-spaces': 2,
    'no-multi-str': 2,
    'no-native-reassign': 2,
    'no-new': 2,
    'no-new-func': 2,
    'no-new-wrappers': 2,
    'no-octal': 2,
    'no-octal-escape': 2,
    'no-param-reassign': [2, { props: true }],
    'no-proto': 2,
    'no-redeclare': [2, { builtinGlobals: true }],
    'no-return-assign': 2,
    'no-script-url': 2,
    'no-self-assign': 2,
    'no-self-compare': 2,
    'no-sequences': 2,
    'no-throw-literal': 2,
    'no-unmodified-loop-condition': 2,
    'no-unused-expressions': 2,
    'no-useless-call': 2,
    'no-useless-concat': 2,
    'no-useless-escape': 2,
    'no-void': 2,
    'no-warning-comments': 1,
    'no-with': 2,
    radix: 2,
    'wrap-iife': 2,
    yoda: 2,

    // ESLint built-in 'Strict Mode' rules
    strict: 2,

    // ESLint built-in 'Variables' rules
    'init-declarations': 2,
    'no-shadow': 2,
    'no-shadow-restricted-names': 2,
    'no-undef': 2,
    'no-undef-init': 2,
    'no-undefined': 2,
    'no-use-before-define': 2,

    // ESLint built-in 'Stylistic Issues' rules
    'array-bracket-spacing': 0,
    'babel/array-bracket-spacing': 2,
    'block-spacing': 2,
    'brace-style': 2,
    'camelcase': 0,
    'comma-spacing': 2,
    'comma-style': 2,
    'computed-property-spacing': 2,
    'consistent-this': 2,
    'eol-last': 2,
    'func-names': 2,
    'func-style': [1, 'expression', {
      allowArrowFunctions: true
    }],
    indent: [2, 2, {
      SwitchCase: 1,
      VariableDeclarator: {
        var: 2,
        let: 2,
        const: 2,
      }
    }],
    'key-spacing': 2,
    'keyword-spacing': 2,
    'linebreak-style': 2,
    'lines-around-comment': [2, {
      beforeBlockComment: true,
      beforeLineComment: true,
      allowBlockStart: true,
      allowObjectStart: true,
      allowArrayStart: true,
    }],
    'new-cap': 0,
    'babel/new-cap': [2, {
      "capIsNewExceptions": [
        "Immutable.List",
        "Immutable.Map",
        "Immutable.Record",
        "Immutable.Set",
        "Immutable.Range"
        ]
    }],
    'new-parens': 2,
    'newline-per-chained-call': 2,
    'no-array-constructor': 2,
    'no-bitwise': 2,
    'no-continue': 2,
    'no-inline-comments': 2,
    'no-lonely-if': 2,
    'no-multiple-empty-lines': 2,
    'no-nested-ternary': 2,
    'no-new-object': 2,
    'no-plusplus': [2, { allowForLoopAfterthoughts: true }],
    'no-spaced-func': 2,
    'no-trailing-spaces': 2,
    'no-underscore-dangle': 2,
    'no-unneeded-ternary': 2,
    'no-whitespace-before-property': 2,
    'object-curly-spacing': 0,
    'babel/object-curly-spacing': [2, 'always'],
    'one-var': [2, 'never'],
    'operator-assignment': [2, 'always'],
    'operator-linebreak': [2, 'after'],
    'quote-props': [2, 'as-needed'],
    quotes: [2, 'single', { avoidEscape: true }],
    semi: 2,
    'semi-spacing': 2,
    'space-before-blocks': 2,
    'space-before-function-paren': [2, 'never'],
    'space-in-parens': 2,
    'space-infix-ops': 2,
    'space-unary-ops': 2,
    'spaced-comment': 2,
    'wrap-regex': 2,

    // ESLint built-in 'ECMAScript 6' rules
    'arrow-body-style': 2,
    'arrow-parens': 0,
    'babel/arrow-parens': [2, 'always'],
    'arrow-spacing': 2,
    'generator-star-spacing': 0,
    'babel/generator-star-spacing': 2,
    'no-confusing-arrow': [2, { allowParens: true }],
    'no-duplicate-imports': 2,
    'no-useless-computed-key': 2,
    'no-useless-constructor': 2,
    'no-var': 2,
    'object-shorthand': 0,
    'babel/object-shorthand': 2,
    'prefer-arrow-callback': 2,
    'prefer-const': 2,
    'prefer-rest-params': 2,
    'prefer-spread': 2,
    'prefer-template': 2,
    'require-yield': 2,
    'template-curly-spacing': 2,

    // eslint-plugin-react rules
    'react/forbid-prop-types': 2,
    'react/no-danger': 2,
    'react/no-set-state': 2,
    'react/no-string-refs': 2,
    'react/no-find-dom-node': 1,
    'react/prefer-es6-class': 2,
    'react/require-render-return': 2,
    'react/self-closing-comp': 2,
    'react/sort-comp': 2,

    // eslint-plugin-babel rules
    // NOTE: Rules fixing built-in ESLint rules are next to the
    //       original rules they override.
    'babel/no-await-in-loop': 2,
  }
};
