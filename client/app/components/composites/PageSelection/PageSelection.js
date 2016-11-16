import _ from 'lodash';
import r, { div, a, p, select, option, span } from 'r-dom';
import classNames from 'classnames';
import { ArrowButton } from '../../elements/RoundButton/RoundButton';
import { upsertSearchQueryParam } from '../../../utils/url';
import { t } from '../../../utils/i18n';
import css from './PageSelection.css';

export default function PageSelection({ className, currentPage, totalPages, location, pageParam }) {
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

  const pageDropdown = span(
    {
      className: css.selectContainer,
    },
    [
      select(
        {
          className: css.select,
          value: currentPage,
          onChange: (event) => {
            const num = parseInt(event.target.value, 10);

            // placeholder for page change without page load
            window.location = getLocation(num);
            return false;
          },
        },
        _.range(1, totalPages + 1)
          .map((page) => option({ value: page }, page))
      ),
    ]
  );

  const prevProps = hasPrev ? {
    onClick: setPage(currentPage - 1),
    href: getLocation(currentPage - 1),
  } : {};

  const nextProps = hasNext ? {
    onClick: setPage(currentPage + 1),
    href: getLocation(currentPage + 1),
  } : {};

  return div({ className: classNames(className, css.pageSelection) }, [
    p({ className: css.pageOf }, [
      t('web.search.page'),
      pageDropdown,
      t('web.search.page_of_pages', { total_number_of_pages: totalPages }),
    ]),
    div({ className: css.arrowButtonsWide }, [
      a(prevProps, r(ArrowButton, { direction: 'left', isDisabled: !hasPrev })),
      a(nextProps, r(ArrowButton, { direction: 'right', isDisabled: !hasNext })),
    ]),
  ]);
}
