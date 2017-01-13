/* eslint-disable no-magic-numbers */

import { expect } from 'chai';
import Immutable from 'immutable';
import { createReader, createWriter } from '../utils/transitImmutableConverter';
import { UUID, Distance, Money } from '../types/types';
import t from 'transit-js';

describe('transitImmutableConverter', () => {

  const reader = createReader();
  const writer = createWriter();
  const rawReader = t.reader('json');
  const rawWriter = t.writer('json');

  it('encodes/decodes keywords', () => {
    const v = ':keyword';
    const encoded = writer.write(v);

    expect(t.isKeyword(rawReader.read(encoded))).to.equal(true);
    expect(Immutable.is(reader.read(encoded), v)).to.equal(true);
  });

  it('encodes/decodes Immutable.Lists', () => {
    const v = Immutable.List([1, 'a', true]);
    const encoded = writer.write(v);

    expect(Array.isArray(rawReader.read(encoded))).to.equal(true);
    expect(Immutable.is(reader.read(encoded), v)).to.equal(true);
  });

  it('encodes/decodes Immutable.Maps', () => {
    const v = Immutable.Map({ a: 1, true: 2 });
    const encoded = writer.write(v);

    expect(t.isMap(rawReader.read(encoded))).to.equal(true);
    expect(Immutable.is(reader.read(encoded), v)).to.equal(true);
  });

  it('encodes/decodes UUIDs', () => {
    const v = new UUID({ value: '00000000-0000-0000-0000-000000000000' });
    const encoded = writer.write(v);

    expect(t.isUUID(rawReader.read(encoded))).to.equal(true);
    expect(Immutable.is(reader.read(encoded), v)).to.equal(true);
  });

  it('encodes/decodes Distances', () => {
    const v = new Distance({ value: '12.3', unit: 'km' });
    const encoded = writer.write(v);

    expect(rawReader.read(encoded).tag).to.equal('di');
    expect(Immutable.is(reader.read(encoded), v)).to.equal(true);
  });

  it('encodes/decodes Money', () => {
    const v = new Money({ value: '500', unit: 'USD' });
    const encoded = writer.write(v);

    expect(rawReader.read(encoded).tag).to.equal('mn');
    expect(Immutable.is(reader.read(encoded), v)).to.equal(true);
  });

  it('decodes URIs', () => {
    const v = 'https://www.sharetribe.com';
    const encoded = rawWriter.write(t.uri(v));

    expect(Immutable.is(reader.read(encoded), v)).to.equal(true);
  });

  it('decodes lists to Immutable.List', () => {
    const v = [1, 2, 3];
    const encoded = rawWriter.write(t.list(v));

    expect(Immutable.is(reader.read(encoded), Immutable.List(v))).to.equal(true);
  });

  it('decodes localized strings', () => {
    const v = { en: 'Hello' };
    const encoded = rawWriter.write(t.tagged('lstr', v));

    expect(Immutable.is(reader.read(encoded), Immutable.Map(v))).to.equal(true);
  });

  it('encodes/decodes deep nested structure with various different types', () => {

    // This is an end-to-end integration test that all the read/write handlers
    // work nicely together.

    const v = Immutable.Map({
      'nested-map': Immutable.Map({
        a: 1,
        b: true,
        c: null,
      }),
      list: Immutable.List([1, 2, 3]),
      uuid: new UUID({ value: '00000000-0000-0000-0000-000000000000' }),
      distance: new Distance({ value: '12.3', unit: 'km' }),
      money: new Money({ fractionalAmount: 500, currency: 'USD' }),
      keyword: ':a',
      int: 1,
      float: 1.2,
      boolean: true,
    });

    expect(Immutable.is(reader.read(writer.write(v)), v)).to.equal(true);
  });

  it("let's you to define custom handlers", () => {
    const Color = function Color(hex) {
      this.hex = hex;
    };

    Color.prototype.valueOf = function valueOf() {
      return this.hex;
    };

    const ColorHandler = t.makeWriteHandler({
      tag: () => 'clr',
      rep: (v) => v.hex,
    });

    const toColor = (rep) => new Color(rep);

    const writeHandlers = [
      Color, ColorHandler,
    ];

    const readHandlers = {
      clr: toColor,
    };

    const reader2 = createReader(readHandlers);
    const writer2 = createWriter(writeHandlers);

    const v = new Color('11FF22');
    const encoded = writer2.write(v);

    expect(rawReader.read(encoded).tag).to.equal('clr');
    expect(Immutable.is(reader2.read(encoded), v)).to.equal(true);
  });
});
