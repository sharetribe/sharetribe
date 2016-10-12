import Immutable from 'immutable';
import { AvatarImage } from './ImageModel';

export const Profile = Immutable.Record({
  familyName: 'family name',
  givenName: 'given name',
  description: 'product author',
  avatarImage: new AvatarImage(),
  profileURL: 'https://example.com/anonym',
});

const parseProfileImage = (image) => {
  const i = image || {};
  return new AvatarImage({
    thumb: i.thumb,
    small: i.small,
    medium: i.medium,
  });
};

export const parse = (profile) => new Profile({
  familyName: profile.getIn([':attributes', ':familyName']),
  givenName: profile.getIn([':attributes', ':givenName']),
  description: profile.getIn([':attributes', ':description']),
  avatarImage: parseProfileImage(profile.getIn([':attributes', ':avatar'])),
  profileURL: 'https://example.com/anonym', // when we get username, find from routes
});
