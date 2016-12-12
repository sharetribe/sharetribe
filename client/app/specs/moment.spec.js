import { expect } from 'chai';
import { expandRange } from '../utils/moment';
import moment from 'moment';
import { List, is } from 'immutable';

describe('moment utils', () => {
  describe('expandRange', () => {
    it('should return expanded range for days', () => {
      const actual = expandRange(moment('2016-12-12'), moment('2016-12-14'), 'days');
      const expected = new List([moment('2016-12-12'), moment('2016-12-13')]);

      expect(is(actual, expected)).to.equal(true);
    });
    it('should return expanded range for months', () => {
      const actual = expandRange(moment('2016-12-01'), moment('2017-02-01'), 'months');
      const expected = new List([moment('2016-12-01'), moment('2017-01-01')]);

      expect(is(actual, expected)).to.equal(true);
    });
    it('should return only full months', () => {
      const actual = expandRange(moment('2016-12-01'), moment('2017-02-15'), 'months');
      const expected = new List([moment('2016-12-01'), moment('2017-01-01')]);
      expect(is(actual, expected)).to.equal(true);
    });
  });
});
