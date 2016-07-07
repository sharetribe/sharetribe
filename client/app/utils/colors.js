
// based on https://www.sitepoint.com/javascript-generate-lighter-darker-color/
const colorLuminance = function ColorLuminance(hexColor, luminance) {
  const lum = luminance || 0;
  // validate hex string
  const hexCode = String(hexColor).replace(/[^0-9a-f]/gi, '');
  const hex = (hexCode.length < 6) ?
    hexCode[0]+hexCode[0]+hexCode[1]+hexCode[1]+hexCode[2]+hexCode[2] :
    hexCode;

  // convert to decimal and change luminosity
  let rgb = '#';
  for (let i = 0; i < 3; i++) {
    const colorComponent = parseInt(hex.substr(i*2,2), 16);
    const alteredCC = Math.round(Math.min(Math.max(0, colorComponent * lum), 255)).toString(16);
    rgb += ('00'+alteredCC).substr(alteredCC.length);
  }

  return rgb;
};

const brightness = function brightness(hex, brightness) {
  const lum = brightness / 100.0;
  return colorLuminance(hex, lum);
}


export { brightness };
