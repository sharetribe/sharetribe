/* eslint-disable no-magic-numbers */

import { expect } from 'chai';

import { fromMidnightUTCDate, toMidnightUTCDate } from '../utils/date';

describe('Date utils', () => {
  describe('fromMidnightUTCDate', () => {
    it('converts midnight UTC dates to local midnight dates', () => {
      // Wednesday 21th Dec, midnight, UTC
      const utc21dec = new Date(Date.UTC(2016, 11, 21, 0, 0, 0, 0));

      // Wednesday 21th Dec, midnight, local timezone
      const local21dec = new Date(2016, 11, 21, 0, 0, 0, 0);

      expect(fromMidnightUTCDate(utc21dec).getTime()).to.equal(local21dec.getTime());
    });
  });

  describe('toMidnightUTCDate', () => {
    it('converts local midnight dates to midnight UTC dates', () => {
      // Wednesday 21th Dec, midnight, UTC
      const utc21dec = new Date(Date.UTC(2016, 11, 21, 0, 0, 0, 0));

      // Wednesday 21th Dec, midnight, local timezone
      const local21dec = new Date(2016, 11, 21, 0, 0, 0, 0);

      expect(toMidnightUTCDate(local21dec).getTime()).to.equal(utc21dec.getTime());
    });
  });
});
