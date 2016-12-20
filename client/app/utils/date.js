/*
   Common utilities for handling JavaScript native Date objects
*/


/* Takes a UTC midnight date and converts it to local midnight date */
export const fromMidnightUTCDate = (d) =>
  new Date(
    d.getUTCFullYear(),
    d.getUTCMonth(),
    d.getUTCDate(),
    0, // h
    0, // min
    0, // s
    0 // ms
  )

/* Takes a JavaScript Date in local timezone and converts it to UTC
midnight date */
export const toMidnightUTCDate = (d) =>
  new Date(
    Date.UTC(
      d.getFullYear(),
      d.getMonth(),
      d.getDate(),
      0, // h
      0, // min
      0, // s
      0 // ms
    ))
