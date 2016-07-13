import _ from 'lodash';

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
    const colorComponent = parseInt(hex.substr(i * 2, 2), 16); // eslint-disable-line no-magic-numbers
    const alteredCC = Math.round(Math.min(Math.max(0, colorComponent * lum), 255)).toString(16); // eslint-disable-line no-magic-numbers
    rgb += (`00${alteredCC}`).substr(alteredCC.length);
  }

  return rgb;
};

const brightness = _.memoize((hex, brightnessPercentage) => {
  const lum = brightnessPercentage / 100.0; // eslint-disable-line no-magic-numbers
  return colorLuminance(hex, lum);
});


export { brightness };
