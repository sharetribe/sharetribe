import _ from 'lodash';
import numbro from 'numbro';
import { t } from './i18n';
import currencies from '../assets/json/currency_iso.json';

const MINIMUM_DISTANCE = 0.1;
const PRECISION = 2;
const DECIMAL_BASE = 10;

// Locales, which are not yet supported by numbro, are not included.
// So, these languages default to en-US formatting.
// el-GR, es-CL, ca-ES, hr-HR, id-ID, is-IS, km-KH, ms-MY,
// ro-RO, sw-KE, vi-VN, bg-BG, mn-MN, zh-HK, ka-GE, sl-SI, ti-ER
const DEFAULT_LOCALE = 'en-US';
const KNOWN_LOCALES = [
  'en-US',
  'da-DK',
  'de-DE',
  'en-AU',
  'en-GB',
  'es-ES',
  'fi-FI',
  'fr-FR',
  'fr-CA',
  'it-IT',
  'ja-JP',
  'nb-NO',
  'nl-NL',
  'pt-BR',
  'pt-PT',
  'ru-RU',
  'sv-SE',
  'tr-TR',
  'zh-CN',
  'en-NZ',
  'et-EE',
  'pl-PL',
  'hu-HU',
  'cs-CZ',
  'th-TH',
  'zh-TW',
  'sk-SK',
];

const initializeNumbro = _.memoize((numbroInstance, locale) => {
  if (locale && _.includes(KNOWN_LOCALES, locale) && locale !== 'en-US') {
    numbroInstance.culture(locale, require(`numbro/languages/${locale}`));
  } else {
    KNOWN_LOCALES.forEach((localeCode) => {
      if (localeCode !== 'en-US') {
        numbroInstance.culture(localeCode, require(`numbro/languages/${localeCode}`));
      }
    });
  }
  return numbroInstance;
}, (numbroInstance, locale) => (locale ? locale : 'all'));

const localizeNumbro = function localizeNumbro(locale) {

  // Ensure that numbro has required all the localization languages and select correct locale
  if (_.includes(KNOWN_LOCALES, locale)) {
    const isServer = typeof window === 'undefined';
    const numbroMultiLang = initializeNumbro(numbro, isServer ? null : locale);
    numbroMultiLang.culture(locale);
    return numbroMultiLang;
  }
  numbro.culture(DEFAULT_LOCALE);
  return numbro;
};

const translateDistanceUnit = function translateDistanceUnit(unit) {
  switch (unit) {
    case ':km':
      return t('web.utils.km');
    case ':miles':
      return t('web.utils.mi');
    default:
      throw new Error('Unknown distance unit');
  }
};

const sigFigs = function sigFigs(n, sig) {
  return parseFloat(n.toPrecision(sig));
};

const formatDistance = function formatDistance(distance, locale = DEFAULT_LOCALE, precision = PRECISION, minimumDistance = MINIMUM_DISTANCE) {
  if (distance == null) {
    return null;
  }

  const localizedNumbro = localizeNumbro(locale);
  const dist = localizedNumbro(sigFigs(distance.value, precision));
  const localizedUnit = translateDistanceUnit(distance.unit);
  const formatted = (distance.value < 1) ? dist.format('0,0.0') : dist.format('0,0');
  const formattedMinimumDistance = localizedNumbro(minimumDistance).format('0.0');

  return (distance.value < minimumDistance) ?
    `< ${formattedMinimumDistance} ${localizedUnit}` :
    `${formatted} ${localizedUnit}`;
};


const formatMoney = (price, locale = DEFAULT_LOCALE) => {
  if (price == null) {
    return null;
  }

  const currencyData = currencies[price.currency.toLowerCase()];
  if (currencyData == null) {
    throw new Error('Unknown currency');
  }

  const localizedNumbro = localizeNumbro(locale);
  const amount = price.fractionalAmount / currencyData.subunit_to_unit;
  const cultureSpecificFormat = localizedNumbro.cultureData().formats.fullWithTwoDecimals;

  return localizedNumbro(amount, price.currency).formatForeignCurrency(currencyData.symbol, cultureSpecificFormat);
};

const toFixedNumber = (number, limit, base) => {
  const pow = Math.pow(base || DECIMAL_BASE, limit);
  return Number(Math.round(number * pow) / pow);
};

export { formatDistance, formatMoney, toFixedNumber };
