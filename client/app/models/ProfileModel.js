import Immutable from 'immutable';

export const Profile = Immutable.Record({
  familyName: 'family name',
  givenName: 'given name',
  description: 'product author',
});

export const parse = (profile) => new Profile({
  familyName: profile.getIn([':attributes', ':familyName']),
  givenName: profile.getIn([':attributes', ':givenName']),
  description: profile.getIn([':attributes', ':description']),
});
