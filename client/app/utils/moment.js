/**
   This file contains utility methods to work with moment JS
   instances.
 */

import Immutable from 'immutable';
import * as date from './date';
import moment from 'moment';

/**
   Takes a time range (`start` and `end` (exclusive)) and returns an Immutable List
   containing the range expanded by the given duration.

   Examples:

   expandRange(moment("2016-12-12"), moment("2016-12-14"), "days")
    -> [moment("2016-12-12"), moment("2016-12-13")]

   expandRange(moment("2016-12-01"), moment("2017-02-01"), "months")
    -> [moment("2016-12-01"), moment("2017-01-01")]

   expandRange(moment("2016-12-01"), moment("2017-02-15"), "months")
    -> [moment("2016-12-01"), moment("2017-01-01")]

   @param {moment} start - range start (inclusive)
   @param {moment} end - range end (exclusive)
   @param {String} duration - minutes|days|months|etc.
*/
export const expandRange = (start, end, duration) =>
  Immutable.Range(0, end.diff(start, duration)).map(
    (i) => start.clone().add(i, duration));

export const fromMidnightUTCDate = (d) =>
  moment(date.fromMidnightUTCDate(d));

export const toMidnightUTCDate = (d) =>
  date.toMidnightUTCDate(d.toDate());
