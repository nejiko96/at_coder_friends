# Change log

## master (unreleased)
### Added
- error handling in fetch_problem.
- remove \mathrm{...} from input format text.

### Changed
- change task id match pattern on submission.
- treat input more than 19 digits as string.

## 0.6.5 (2020-04-15)
### Added
- multiple language version support.

## 0.6.4 (2020-03-08)
### Added
- Modulo RegExp pattern.

### Changed
- minor changes in ERBs.
- allow underscores in problem ID.
- allow whitespaces in data file path.

### Deleted
- remove tasks folder from installation

## 0.6.3 (2020-01-05)
### Added
- 'vertical array + matrix' input format support.
- 'matrix + vertical array' input format support.
- 'vertically expanded matrices' input format support.
- 'horizontally expanded matrices' input format support.
- decimal type support.
- input data with delimiter(- : /) support.
- input data of mixed type support.
- input of N-1 lines support.

### Changed
- Change template file format to ERB.
- Template file integration

### Deleted
- Template file for interactive problems.
- '### OUTPUT ###' embedding pattern.
- '### URL ###' embedding pattern.

## 0.6.2 (2019-11-18)
### Added
- add ```check-and-go``` command.

### Changed
- Enhancement in input format parser.

## 0.6.1 (2019-10-28)
### Added
- Extract MOD values from problem description.

### Changed
- Enhancement in MAX value parser.

## 0.6.0 (2019-10-21)
### Added
- Output problem url to generated sources.
- Interactive problem support.
- Binary problem support.
- Add settings about source generation.

### Changed
- Treat all ```A_*.in``` format files as sample input data

## 0.5.2 (2019-10-14)
### Fixed
- Fix input format parser.

## 0.5.1 (2019-10-14)
### Added
- Colored test results.

### Changed
- Enhancement in sample data parser.
- Enhancement in input format parser.

## 0.5.0 (2019-10-04)
### Added
- User/password setting in ```.at_coder_friends.yml``` is no longer required.
- Saving and restoring session feature.

## 0.4.0 (2019-09-16)
### Added
- Test and submission are now available in 36 languages.

## 0.3.3 (2019-09-01)
### Added
- Add ```open-contest-page``` command.
