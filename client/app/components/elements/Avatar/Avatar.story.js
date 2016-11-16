import r from 'r-dom';
import { shallow } from 'enzyme';
import { storify } from '../../Styleguide/withProps';

import Avatar from './Avatar';
import { Image } from '../../../models/ImageModel';

const { storiesOf, specs, expect } = storybookFacade;
const containerStyle = { style: { background: 'grey', width: '60px', height: '60px' } };

const avatarProps = {
  image: new Image({ url: 'https://www.gravatar.com/avatar/d0865b2133d55fd507639a0fd1692b9a' }),
  givenName: 'First',
  familyName: 'Last',
};

storiesOf('Top bar')
  .add('Avatar with image', () => {
    const avatar = r(Avatar, avatarProps);
    const shallowed = shallow(avatar);
    specs(() => describe('Avatar with image', () => {
      it('Should have alt text', () => {
        expect(shallowed.html('img')).to.contain('First Last');
      });
    }));
    return r(storify(avatar, containerStyle));
  })
  .add('Avatar without image', () => {
    const avatar = r(Avatar, { ...avatarProps, ...{ image: null } });
    const shallowed = shallow(avatar);
    specs(() => describe('Avatar without image', () => {
      it('should show user initials', () => {
        expect(shallowed.text()).to.contain('FL');
      });
    }));
    return r(storify(avatar, containerStyle));
  })
  .add('Avatar without image, only given name', () => {
    const avatar = r(Avatar, { givenName: 'F' });
    const shallowed = shallow(avatar);
    specs(() => describe('Avatar without image, only given name', () => {
      it('should show user initials', () => {
        expect(shallowed.text()).to.contain('F');
      });
    }));
    return r(storify(avatar, containerStyle));
  })
  .add('Avatar without image, only last name', () => {
    const avatar = r(Avatar, { familyName: 'L' });
    const shallowed = shallow(avatar);
    specs(() => describe('Avatar without image, only last name', () => {
      it('should show user initials', () => {
        expect(shallowed.text()).to.contain('L');
      });
    }));
    return r(storify(avatar, containerStyle));
  });
