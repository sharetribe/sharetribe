import { Component, PropTypes } from 'react';
import r, { a, div, img, span } from 'r-dom';
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
import plusIcon from './images/plusIcon.svg';

const TINT_PERCENTAGE = 20;
const IMAGE_LOADING_TIMEOUT = 10000;
const IMAGE_TIMEOUT_TYPE_ERROR = 'Force image resolve as error';
const IMAGE_LOADING = 'loading';
const IMAGE_LOADED = 'loaded';
const IMAGE_FAILED = 'failed';


const delayedPromiseCurry = (timeoutRefs) => (timeMs, name) => (
  new Promise((resolve) => (
    timeoutRefs.push({ name, timeout: setTimeout(resolve, timeMs) })
  ))
);

const clearTimeouts = (timeouts, name = null) => {
  timeouts.forEach((to) => {
    if (name == null || to.name === name) {
      window.clearTimeout(to.timeout);
    }
  });
};

const triggerImgLoad = (image) => {
  if (image.complete && image.naturalHeight > 0) {
    const event = document.createEvent('UIEvent');
    event.initEvent('load', true, true);
    image.dispatchEvent(event);
  }
};

const triggerImgError = (image, forceError = false) => {
  const forCompleted = !forceError && image.complete;
  const hasNoHeight = image.naturalHeight === 0;

  if ((forCompleted && hasNoHeight) || (forceError && hasNoHeight)) {
    const event = document.createEvent('UIEvent');
    event.initEvent('error', true, true);
    image.dispatchEvent(event);
  }
};

const triggerInitialImgStatuses = (image) => {
  triggerImgLoad(image);
  triggerImgError(image);
};

class ListingCard extends Component {

  constructor(props, context) {
    super(props, context);
    this.state = { imageStatus: IMAGE_LOADING };

    this.imageRef = null;
    this.timeouts = [];
    this.delay = delayedPromiseCurry(this.timeouts);

    this.handleImageLoaded = this.handleImageLoaded.bind(this);
    this.handleImageErrored = this.handleImageErrored.bind(this);
    this.clickHandler = this.clickHandler.bind(this);
  }

  componentDidMount() {
    const ref = this.imageRef;
    if (canUseDOM && ref != null) {
      if (ref.complete) {
        triggerInitialImgStatuses(ref);
      } else {
        this.delay(IMAGE_LOADING_TIMEOUT, IMAGE_TIMEOUT_TYPE_ERROR)
          .then(() => {
            triggerImgError(ref, true);
          });
      }
    }
  }

  shouldComponentUpdate(nextProps, nextState) {
    return this.state.imageStatus !== nextState.imageStatus;
  }

  componentWillUnmount() {
    this.timeouts.forEach((to) => window.clearTimeout(to.timeout));
  }

  handleImageLoaded() {
    clearTimeouts(this.timeouts, IMAGE_TIMEOUT_TYPE_ERROR);
    this.setState({ imageStatus: IMAGE_LOADED }); // eslint-disable-line react/no-set-state
  }

  handleImageErrored() {
    clearTimeouts(this.timeouts, IMAGE_TIMEOUT_TYPE_ERROR);
    this.setState({ imageStatus: IMAGE_FAILED }); // eslint-disable-line react/no-set-state
  }

  clickHandler(event) {
    if (canUseDOM) {
      if (event.shiftKey || event.ctrlKey || event.metaKey) {
        event.preventDefault();
        window.open(this.props.listing.listingURL, '_blank');
      } else {
        window.location = this.props.listing.listingURL;
      }
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
        ref: (c) => {
          this.imageRef = c;
        },
      },
      ...higherRes,
    });

    const addImage = div({
      className: css.noImageText,
    }, a({
      className: css.noImageLink,
      href: listing.listingURLEdit,
    }, [
      span({ dangerouslySetInnerHTML: { __html: plusIcon } }),
      t('web.listing_card.add_picture'),
    ]));

    const noImage = div({
      className: css.noImageText,
    }, t('web.listing_card.no_picture'));

    const imgPlaceholder = this.props.loggedInUserIsAuthor ? addImage : noImage;

    const noListingImage = div({ className: classNames('ListingCard_noImage', css.noImageContainer) },
      div(
        { className: css.noImageWrapper },
        [
          div({
            className: css.noImageIcon,
            dangerouslySetInnerHTML: { __html: noImageIcon },
          }),
          imgPlaceholder,
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
      div({
        className: css.squareWrapper,
        style: { backgroundColor: `rgb(${tintedRGB.r}, ${tintedRGB.g}, ${tintedRGB.b})` },
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
  loggedInUserIsAuthor: string,
};

export default ListingCard;
