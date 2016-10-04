import { Component, PropTypes } from 'react';
import r, { a, div, img } from 'r-dom';
import classNames from 'classnames';
import { t, currentLocale } from '../../../utils/i18n';
import { canUseDOM } from '../../../utils/featureDetection';
import { tint } from '../../../utils/colors';
import { formatDistance, formatPrice } from '../../../utils/numbers';
import ListingModel from '../../../models/ListingModel';

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
    this.clickHandler = this.clickHandler.bind(this);
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

  clickHandler() {
    if (canUseDOM) {
      window.location = this.props.listing.listingURL;
    }
  }

  render() {
    const tintedRGB = tint(this.props.color, TINT_PERCENTAGE);
    const listing = this.props.listing;
    const imageURL = listing.images.getIn([0, 'square', 'url']);
    const image2xURL = listing.images.getIn([0, 'square2x', 'url']);
    const higherRes = image2xURL ? { srcSet: `${image2xURL} 2x` } : null;

    const localeInfo = currentLocale();
    if (!(localeInfo && localeInfo["language"] && localeInfo["region"])) {
      console.log('localeInfo', localeInfo);
      console.log('localeInfo', localeInfo.ident);
      throw new Error('Unknown locale');
    }

    const fullLocaleCode = `${localeInfo["language"].toLowerCase()}-${localeInfo["region"].toUpperCase()}`;
    const distanceFormatted = formatDistance(listing.distance, fullLocaleCode);
    const priceFormatted = listing.price ? formatPrice(listing.price, fullLocaleCode): null;

    return div({
      className: classNames('ListingCard', css.listing, this.props.className),
      'data-listing-id': listing.id,
      onClick: this.clickHandler,
    }, [
      a({
        className: css.squareWrapper,
        style: { backgroundColor: `rgb(${tintedRGB.r}, ${tintedRGB.g}, ${tintedRGB.b})` },
        href: listing.listingURL,
      }, imageURL && this.state.imageStatus !== 'failed' ?
        img({
          ...{
            className: classNames('ListingCard_image', css.thumbnail),
            src: imageURL,
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
            }, t('web.listing_card.no_picture')),
          ]),
        ),
      ),
      div({ className: css.info }, [
        div({
          className: css.avatarPosition,
        }, r(Avatar, {
          url: listing.profileURL,
          image: listing.avatarURL,
          color: this.props.color,
        })),
        a({
          className: css.title,
          href: listing.listingURL,
        }, [
          div({
            className: css.avatarSpacer,
          }),
          listing.title,
        ]),
        div({ className: css.footer }, [
          listing.price ?
            div({
              className: css.priceWrapper,
              style: { color: this.props.color },
            }, [
              div({ className: css.price }, priceFormatted),
              listing.per ?
                div({ className: css.per }, listing.per) :
                null,
            ]):
            div({ className: css.priceWrapper }),
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


const { instanceOf, string } = PropTypes;

ListingCard.propTypes = {
  className: string,
  color: string.isRequired,
  listing: instanceOf(ListingModel).isRequired,
};

export default ListingCard;
