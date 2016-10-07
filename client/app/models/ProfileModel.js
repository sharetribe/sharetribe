import Immutable from 'immutable';

export const Profile = Immutable.Record({
  familyName: 'family name',
  givenName: 'given name',
  description: 'product author',
  avatarURL: null,
  profileURL: 'https://example.com/anonym',
});

export const parse = (profile) => new Profile({
  familyName: profile.getIn([':attributes', ':familyName']),
  givenName: profile.getIn([':attributes', ':givenName']),
  description: profile.getIn([':attributes', ':description']),
  avatarURL: null,
  profileURL: 'https://example.com/anonym', // when we get username, find from routes
});
