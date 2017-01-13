import { expect } from 'chai';
import { formatDistance, formatMoney, toFixedNumber } from '../utils/numbers';
import { Distance, Money } from '../types/types';

describe('Number utils', () => {
  describe('Formatting distance', () => {
    it('Should format distance as "10,000 mi" with en-US', () => {
      expect(formatDistance(new Distance({ value: 10000, unit: ':miles' }), 'en-US')).to.equal('10,000 mi');
    });
    it('Should format distance as "10 000 km" with fi-FI', () => {
      expect(formatDistance(new Distance({ value: 10000, unit: ':km' }), 'fi-FI')).to.equal('10 000 km');
    });
    it('Should return null, if no distance given', () => {
      expect(formatDistance(null, 'en-US')).to.equal(null);
    });
  });

  describe('Formatting Money', () => {
    it('Should format price as "$ 10,000" with en-US', () => {
      expect(formatMoney(new Money({ fractionalAmount: 1000000, currency: 'USD' }), 'en-US')).to.equal('$ 10,000.00');
    });
    it('Should format distance as "10 000 €" with fi-FI', () => {
      expect(formatMoney(new Money({ fractionalAmount: 1000000, currency: 'EUR' }), 'fi-FI')).to.equal('10 000,00 €');
    });
    it('Should return null, if no distance given', () => {
      expect(formatMoney(null, 'en-US')).to.equal(null);
    });
    it('Should throw error with unknown currency', () => {
      expect(() => formatMoney(new Money({ fractionalAmount: 100, currency: 'XXX' }), 'en-US')).to.throw('Unknown currency');
    });
  });

  describe('Formatting Number with toFixedNumber', () => {
    it('Should format Number(23.56576) with precision 2 to Number(23.57)', () => {
      const fixedNumber = toFixedNumber(23.56576, 2); // eslint-disable-line no-magic-numbers
      expect(fixedNumber).to.equal(Number(23.57));  // eslint-disable-line no-magic-numbers
      expect(fixedNumber).to.be.a('number');
    });
  });

});
