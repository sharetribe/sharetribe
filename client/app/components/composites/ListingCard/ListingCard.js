import { Component, PropTypes } from 'react';
import r, { a, div, img } from 'r-dom';
import classNames from 'classnames';
import { tint } from '../../../utils/colors';
import { formatDistance, formatPrice } from '../../../utils/numbers';

import Avatar from '../../elements/Avatar/Avatar';
import css from './ListingCard.css';
import noImageIcon from './images/noImageIcon.svg';
import distanceIcon from './images/distanceIcon.svg';

const TINT_PERCENTAGE = 20;


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
    const higherRes = this.props.image2xURL ? { srcSet: `${this.props.image2xURL} 2x` } : null;
    const distanceFormatted = formatDistance(this.props.distance, this.props.distanceUnit);
    const priceFormatted = formatPrice(this.props.price, this.props.priceUnit);

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
          ...{
            className: css.thumbnail,
            src: this.props.imageURL,
            onLoad: this.handleImageLoaded,
            onError: this.handleImageErrored,
          },
          ...higherRes,
        }) :
        div({
          className: css.noImageContainer,
        }, div(
          {
            className: css.noImageWrapper,
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
          distanceFormatted ?
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
  image2xURL: string,
  listingURL: string.isRequired,
  noImageText: string.isRequired,
  per: string,
  profileURL: string.isRequired,
  price: number.isRequired,
  priceUnit: string.isRequired,
  title: string.isRequired,

};

export default ListingCard;
