import r, { div } from 'r-dom';

const withProps = function withProps(component, props) {
  return div([
    r(component, props),
    r.strong({ style: { marginTop: '2em', display: 'block' } }, 'Props:'),
    r.pre({
      style: {
        marginTop: '1em',
        background: 'lightGrey',
        padding: '1em',
        display: 'inline-block',
      } },
      JSON.stringify(props, null, '  ')),
  ]);
};

export default withProps;
