# Release

When ready to release - follow these steps:

1. Bump up the [VERSION](VERSION)

2. Update [CHANGELOG.md](CHANGELOG.md)

* Replace the \[Unreleased\] with the version number.
* Add a new \[Unreleased\] version.

3. Update [UPGRADE.md](UPGRADE.md)

* See if there are any upgrade notes. If not, you can move to next step.
* Replace the \[Unreleased\] with the correct version number.
* Add a new \[Unreleased\] version

4. Commit the changes

5. Add a new tag

```bash
git tag -a v5.0.0 -m v5.0.0
```

6. Push the tag

```bash
git push --tags
```

7. Go to Github releases and draft a new release

Use the following content:

**Tag version:** <the newly created tag>

**Release title:** <version number>

**Describe this release:**

```markdown
## Change Log

<copy the content from the [CHANGELOG.md](UPGRADE.md)>

## Upgrade from x.x.x to y.y.y

<copy the content from the [UPGRADE.md](UPGRADE.md)>
```

Here's a full example:

**Tag version:** v5.0.0

**Release title:** v5.0.0

**Describe this release:**

```markdown
## Change Log

### Changed

- Rails upgraded from 3.2 to 4.0

## Upgrade from 4.6.0 to 5.0.0

After you have deployed the new version you need to clear Rails cache by running to following command in your production application Rails console:
```
