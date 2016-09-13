import _ from 'lodash';

const COLOR_FF = 255;
const HEXADECIMAL = 16;
const PERCENTAGE_100 = 100.0;

const hexToRGB = _.memoize((hexadecimal) => {
  // Expand shorthand form (e.g. "03F") to full form (e.g. "0033FF")
  const shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
  const hex = hexadecimal.replace(shorthandRegex, (m, r, g, b) => r + r + g + g + b + b);

  const result = (/^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i).exec(hex);
  return result ? {
    r: parseInt(result[1], HEXADECIMAL),
    g: parseInt(result[2], HEXADECIMAL),
    b: parseInt(result[3], HEXADECIMAL),
  } : null;
});

// based on https://www.sitepoint.com/javascript-generate-lighter-darker-color/
const colorLuminance = function ColorLuminance(hexColor, luminance) {
  const lum = luminance || 0;

  // validate hex string
  const hexCode = String(hexColor).replace(/[^0-9a-f]/gi, '');
  const hex = (hexCode.length < 6) ? // eslint-disable-line no-magic-numbers
    hexCode[0] + hexCode[0] + hexCode[1] + hexCode[1] + hexCode[2] + hexCode[2] :
    hexCode;

  // convert to decimal and change luminosity
  let rgb = '#';
  for (let i = 0; i < 3; i++) { // eslint-disable-line no-magic-numbers
    const colorComponent = parseInt(hex.substr(i * 2, 2), HEXADECIMAL); // eslint-disable-line no-magic-numbers
    const alteredCC = Math.round(Math.min(Math.max(0, colorComponent * lum), COLOR_FF)).toString(HEXADECIMAL);
    rgb += (`00${alteredCC}`).substr(alteredCC.length);
  }

  return rgb;
};

const brightness = _.memoize((hex, brightnessPercentage) => {
  const lum = brightnessPercentage / PERCENTAGE_100;
  return colorLuminance(hex, lum);
});


const tint = _.memoize((hex, tintPercentage) => {
  const rgb = hexToRGB(hex);
  const tintRatio = tintPercentage / PERCENTAGE_100;

  // Tint
  return {
    r: Math.round(tintRatio * rgb.r + (1 - tintRatio) * COLOR_FF),
    g: Math.round(tintRatio * rgb.g + (1 - tintRatio) * COLOR_FF),
    b: Math.round(tintRatio * rgb.b + (1 - tintRatio) * COLOR_FF),
  };
});

export { brightness, hexToRGB, tint };
