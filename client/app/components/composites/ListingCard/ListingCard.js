import { Component, PropTypes } from 'react';
import r, { a, div, img } from 'r-dom';
import classNames from 'classnames';
import { tint } from '../../../utils/colors';

import Avatar from '../../elements/Avatar/Avatar';
import css from './ListingCard.css';
import noImageIcon from './images/noImageIcon.svg';
import distanceIcon from './images/distanceIcon.svg';

const MINIMUM_DISTANCE = 0.1;
const PRECISION = 2;
const TINT_PERCENTAGE = 20;

const sigFigs = function sigFigs(n, sig) {
  return parseFloat(n.toPrecision(sig));
};

class ListingCard extends Component {

  constructor(props, context) {
    super(props, context);
    this.state = { imageStatus: 'loading' };

    this.handleImageLoaded = this.handleImageLoaded.bind(this);
    this.handleImageErrored = this.handleImageErrored.bind(this);
  }

  shouldComponentUpdate(nextProps, nextState) {
    return this.state.imageStatus !== nextState.imageStatus;
  }

  handleImageLoaded() {
    this.setState({ imageStatus: 'loaded' }); // eslint-disable-line react/no-set-state
  }

  handleImageErrored() {
    this.setState({ imageStatus: 'failed' }); // eslint-disable-line react/no-set-state
  }

  render() {

    const tintedRGB = tint(this.props.color, TINT_PERCENTAGE);
    const hasDistance = !!this.props.distance;
    const precision = (hasDistance && this.props.distance < 1) ? 1 : PRECISION;
    const distanceFormatted = (hasDistance && this.props.distance < MINIMUM_DISTANCE) ? `< 0.1${this.props.distanceUnit}` : `${sigFigs(this.props.distance, precision)}${this.props.distanceUnit}`;

    const priceFormatted = `${this.props.priceUnit} ${this.props.price}`;

    return div({
      className: classNames(css.listing, this.props.className),
      'data-listing-id': this.props.id,
    }, [
      a({
        className: css.squareWrapper,
        style: { backgroundColor: `rgb(${tintedRGB.r}, ${tintedRGB.g}, ${tintedRGB.b})` },
        href: this.props.listingURL,
      }, this.props.imageURL && this.state.imageStatus !== 'failed' ?
        img({
          className: css.thumbnail,
          src: this.props.imageURL,
          onLoad: this.handleImageLoaded,
          onError: this.handleImageErrored,
        }) :
        div({
          className: css.noImageContainer,
        }, div(
          {
            className: css.noImagaWrapper,
          }, [
            div({
              className: css.noImageIcon,
              dangerouslySetInnerHTML: { __html: noImageIcon },
            }),
            div({
              className: css.noImageText,
            }, this.props.noImageText),
          ]),
        ),
      ),
      div({ className: css.info }, [
        div({
          className: css.avatarPosition,
        }, r(Avatar, {
          url: this.props.profileURL,
          image: this.props.avatarURL,
          color: this.props.color,
        })),
        a({
          className: css.title,
          href: this.props.profileURL,
        }, [
          div({
            className: css.avatarSpacer,
          }),
          this.props.title,
        ]),
        div({ className: css.footer }, [
          div({
            className: css.priceWrapper,
            style: { color: this.props.color },
          }, [
            div({ className: css.price }, priceFormatted),
            this.props.per ?
              div({ className: css.per }, this.props.per) :
              null,
          ]),
          hasDistance ?
            div({ className: css.distance }, [
              div({
                className: css.distanceIcon,
                dangerouslySetInnerHTML: { __html: distanceIcon },
              }),
              distanceFormatted,
            ]) :
            null,
        ]),
      ]),
    ]);
  }
}


const { number, string } = PropTypes;

ListingCard.propTypes = {
  avatarURL: string.isRequired,
  className: string,
  color: string.isRequired,
  distance: number,
  distanceUnit: string,
  id: string.isRequired,
  imageURL: string,
  listingURL: string.isRequired,
  noImageText: string.isRequired,
  per: string,
  profileURL: string.isRequired,
  price: number.isRequired,
  priceUnit: string.isRequired,
  title: string.isRequired,

};

export default ListingCard;
