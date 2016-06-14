import { Component } from 'react';
import r, { div } from 'r-dom';
import { storiesOf } from '@kadira/storybook';
import _ from 'lodash';

import cssVariables from '../../assets/styles/variables';
import css from './ColorsAndTypography.css';

const colors = _.chain(cssVariables)
        .toPairs()
        .filter(([name]) => name.startsWith('--color'))
        .fromPairs()
        .value();

class Colors extends Component {
  colorSwatch(color, title) {
    const colorTitle = title || color;
    return (
      div({ className: css.colorSwatch, style: { backgroundColor: color } }, [
        div({ className: css.colorCode }, colorTitle),
      ])
    );
  }

  swatches(colorCollection) {
    return _(colorCollection).map((colorCode, colorName) =>
      this.colorSwatch(colorCode, colorName)
    );
  }

  render() {
    return div([
      div({ className: css.section }, [
        div({ className: css.sectionHead }, 'Main colors'),
        ...this.swatches(colors),
      ]),
    ]);
  }
}

class Typography extends Component {
  render() {
    return div([
      r.h1('Heading 1'),
      r.p('Paragraph text'),
      r.h2('Heading 2'),
      r.p('Oltiin tänää kukko pärssisen kanssa PANIIKISSA tekemässä C-KOODIA ku joku hiiri (epäilemättä fuksi) tuli kyselemään apua et miten PYTHONISSA toteutetaan oikeaoppinen moniperintä!! Kelatkaa, tulee meiltä kysymään tällasta, vaikka kaikki tietää ette me ei TODELLAKAAN koodata tulkattuja tai VM kieliä!!! Käskettiin sen painua MAARILLE pyytämään neuvoja joltain PYTHON 1 kurssin assarilta tai vaihtoehtosesti VARTIJALTA (taitotaso samalla tasolla!!!). Kaveri lähtee siitä lätkimään tosi nopeesti hätääntyneenä ja unohtaa vielä puolikkaan MAD CROCIN pöydälle. Kaikkea sitä pitääki todistaa.'),
      r.p('Another paragraph.'),
      r.h3('Heading 3'),
      r.p('Tullaan myöhemmin lounaalta, ja kelatkaa, tää sama kaveri istuu kukkon VAKIPAIKALLA ja ähertää siinä tomerasti jotain. Mennään kattomaan lähempää ni kaverilla on ECLIPSE auki ja väkertää sillä jotain PYTHONIA tai muuta amatöörien ja FUKSIEN kieltä! Ollaan ällikällä lyötyjä tän kaverin amatöörimäisyydestä, KAIKKI TIETÄÄ että koodia ei todellakaan kirjoteta muuta ku VIMILLÄ tai suoraan reikäkorteille! Kukko heittää siihen heti: "Meinaatko ihan KVANTTITASOLLE mennä tolla eclipsellä!" (en tiedä mistä se keksii näitä.. varmaan jotain sähköjuttuja, Kukko opiskelee tietysti SÄHKÖLLÄ koska kukon mukaan siellä liikutaan RAUDAN ALAPUOLELLA!!!!).  Kaveri sössöttää siihen takas ettei kuulemma tiedä mikä on kvantti kun ei oo vielä käyny kvanttifysiikan KURSSIA!! Kaveri yrittää selkeesti bluffata meitä koska tää JÄTKÄ ei todellakaan voi olla muualta kun INFOLTA missä ei todellakaan käydä KVANTTIFYSIIKKAA!! Kukko muistuttaa kaverille et eikös tänää illalla olla HAVAITSEMISEN kurssin leikekirja-projektityön (koko kurssin ainut suoritus!!! ei tenttiä!!) palautus ( miten se muistaa näitä !?!?!?!). Kaveri katoo siitä ku pieru saharaan ja jättää tunnarit auki koneeseen. Ajetaan tietysti RAINBOW TABLEJA kaverin tunnareilla niksula ADMIN SALASANAA VASTAAN!! Tästä tulee taatusti sille ONGELMIA. Oppiipaahan että MEILLE EI TODELLAKAAN VALEHDELLA!!!'),
    ]);
  }
}


storiesOf('Colors and typography')
  .add('Colors', () => (
    r(Colors)))
  .add('Typography', () => (
    r(Typography)));
