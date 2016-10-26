import r, { div, a } from 'r-dom';
import { ArrowButton } from '../../elements/RoundButton/RoundButton';
import { upsertSearchQueryParam } from '../../../utils/url';

import css from './PageSelection.css';

export default function PageSelection({ currentPage, totalPages, location, pageParam }) {
  const hasNext = totalPages > currentPage;
  const hasPrev = currentPage > 1;

  const getLocation = (num) => {
    const newParams = upsertSearchQueryParam(location, pageParam, num);
    const locationBase = location.split('?')[0];
    return `${locationBase}?${newParams}`;
  };

  const setPage = (num) =>
    (e) => {
      e.preventDefault();

      // placeholder for page change without page load
      window.location = getLocation(num);
      return false;
    };

  const buttonsVisible = [hasPrev, hasNext].filter((x) => x).length;
  const className = buttonsVisible === 2 ? css.arrowButtonsWide : css.arrowButtonsNarrow; // eslint-disable-line no-magic-numbers

  return div({ className: css.pageSelection }, [
    `Page ${currentPage} of ${totalPages} `,
    div({ className }, [
      hasPrev ? a({
        onClick: setPage(currentPage - 1),
        href: getLocation(currentPage - 1) },
        r(ArrowButton, { direction: 'left' })) : null,
      hasNext ? a({
        onClick: setPage(currentPage + 1),
        href: getLocation(currentPage + 1) },
        r(ArrowButton, { direction: 'right' })) : null,
    ]),
  ]);
}
