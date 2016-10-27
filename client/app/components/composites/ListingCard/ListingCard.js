import { Component, PropTypes } from 'react';
import r, { a, div, img } from 'r-dom';
import classNames from 'classnames';
import { t, fullLocaleCode, localizedString, localizedPricingUnit } from '../../../utils/i18n';
import { canUseDOM } from '../../../utils/featureDetection';
import { tint, avatarColor } from '../../../utils/colors';
import { formatDistance, formatMoney } from '../../../utils/numbers';
import ListingModel from '../../../models/ListingModel';

import Avatar from '../../elements/Avatar/Avatar';
import css from './ListingCard.css';
import noImageIcon from './images/noImageIcon.svg';
import distanceIcon from './images/distanceIcon.svg';

const TINT_PERCENTAGE = 20;
const IMAGE_LOADING = 'loading';
const IMAGE_LOADED = 'loaded';
const IMAGE_FAILED = 'failed';

class ListingCard extends Component {

  constructor(props, context) {
    super(props, context);
    this.state = { imageStatus: IMAGE_LOADING };

    this.handleImageLoaded = this.handleImageLoaded.bind(this);
    this.handleImageErrored = this.handleImageErrored.bind(this);
    this.clickHandler = this.clickHandler.bind(this);
  }

  shouldComponentUpdate(nextProps, nextState) {
    return this.state.imageStatus !== nextState.imageStatus;
  }

  handleImageLoaded() {
    this.setState({ imageStatus: IMAGE_LOADED }); // eslint-disable-line react/no-set-state
  }

  handleImageErrored() {
    this.setState({ imageStatus: IMAGE_FAILED }); // eslint-disable-line react/no-set-state
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

    const localeCode = fullLocaleCode();
    const distanceFormatted = formatDistance(listing.distance, localeCode);
    const price = listing.price;
    const moneyFormatted = price ? formatMoney(price.get(':money'), localeCode) : null;
    const hasPricingUnit = price && price.get(':pricingUnit') != null && price.get(':pricingUnit').get(':unit') != null;
    const pricingUnitFormatted = hasPricingUnit ?
      `/ ${localizedPricingUnit(price.get(':pricingUnit'))}` :
      '';
    const orderTypeLabel = localizedString(listing.orderType, 'order type');

    const listingImage = img({
      ...{
        className: classNames('ListingCard_image', css.thumbnail),
        src: imageURL,
        onLoad: this.handleImageLoaded,
        onError: this.handleImageErrored,
      },
      ...higherRes,
    });

    const noListingImage = div({ className: css.noImageContainer },
      div(
        { className: css.noImageWrapper },
        [
          div({
            className: css.noImageIcon,
            dangerouslySetInnerHTML: { __html: noImageIcon },
          }),
          div({
            className: css.noImageText,
          }, t('web.listing_card.no_picture')),
        ]
      )
    );

    const imageOrPlaceholder = imageURL && this.state.imageStatus !== IMAGE_FAILED ?
      listingImage :
      noListingImage;

    return div({
      className: classNames('ListingCard', css.listing, this.props.className),
      onClick: this.clickHandler,
    }, [
      a({
        className: css.squareWrapper,
        style: { backgroundColor: `rgb(${tintedRGB.r}, ${tintedRGB.g}, ${tintedRGB.b})` },
        href: listing.listingURL,
      }, div({ className: css.aspectWrapper }, imageOrPlaceholder)
      ),
      div({ className: css.info }, [
        div({
          className: css.avatarPosition,
        }, r(Avatar, {
          url: listing.author.profileURL,
          image: listing.author.avatarImage ? listing.author.avatarImage.thumb : null,
          color: avatarColor(`${listing.author.givenName}${listing.author.familyName}`) || this.props.color,
          givenName: listing.author.givenName,
          familyName: listing.author.familyName,
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
          price ?
            div({
              className: css.orderTypeWrapper,
              style: { color: this.props.color },
            }, [
              div({ className: classNames('ListingCard_price', css.price), title: price.get(':money').currency }, moneyFormatted),
              hasPricingUnit ?
                div({ className: css.per }, pricingUnitFormatted) :
                null,
            ]) :
            div({
              className: classNames('ListingCard_orderType', css.orderTypeWrapper),
              style: { color: this.props.color },
            }, orderTypeLabel),
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
