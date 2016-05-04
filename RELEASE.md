# Release

When you are ready to release a new version, follow these steps:

1. Bump up the [VERSION](VERSION)

2. Update [CHANGELOG.md](CHANGELOG.md)

  * Replace the \[Unreleased\] with the version number.
  * Add current date to version number line.
  * Add a new \[Unreleased\] version.
  * Add a git diff link to the end of the file, and update the `unreleased` diff link.

3. Update [UPGRADE.md](UPGRADE.md)

  * See if there are any upgrade notes. If not, you can move to next step.
  * Replace the \[Unreleased\] with the correct version number.
  * Add a new \[Unreleased\] version

4. Commit the changes

5. Add a new tag

  ```bash
  git tag -a v1.2.3 -m v1.2.3
  ```

6. Push the tag

  ```bash
  git push --tags
  ```

7. Go to Github releases and draft a new release

  Use the following content:

  **Tag version:** \<the newly created tag\>

  **Release title:** \<version number\>

  **Describe this release:**

  ```markdown
  <copy the content from the [CHANGELOG.md](CHANGELOG.md)>
  <copy the content from the [UPGRADE.md](UPGRADE.md)>
  ```

  Here's a full example:

  **Tag version:** v5.0.0

  **Release title:** v5.0.0

  **Describe this release:**

  ```markdown
  ### Changed

  - Rails upgraded from 3.2 to 4.0

  ## Upgrade from 4.6.0 to 5.0.0

  After you have deployed the new version you need to clear Rails cache by running to following command in your production application Rails console:
  ```

8. Announce the new version at the [Open Source Community Forum](https://www.sharetribe.com/community/c/os-announcements)
