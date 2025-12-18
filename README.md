<a name="readme-top"></a>

<h1 align="center"><a href="https://github.com/jwoo92/database-answers.com"><img src="images/database-answers-logo.jpeg" alt="Logo"></a></h1>

<!-- TABLE OF CONTENTS -->
<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>
<div align="center">

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

</div>
<div align="center">
  <h3 align="center"><a href="https://database-answers.com">database-answers.com</a></h3>
  <p align="center">Archive revival of Database Answers</p>
</div>

## Overview

<a href="https://web.archive.org/web/20200721175643/databaseanswers.org">Database Answers <em>(archive.org)</em></a> served as an outstanding resource during my exploration of data design, and it disheartened me to learn of its discontinuation.

My intention behind this revival is to carry on its legacy and help both myself and others who may benefit from it.

Database Answers was a website that had a dedicated focus on offering resources and guidance related to database design and management.

The website offered solutions to prevalent challenges regarding databases, intending to aid individuals and businesses in developing efficient and well-organized database systems.

It featured articles, tutorials, and tools to support users in improving their approach to database design and implementation.

![Database Answers Screenshot][website-screenshot]

## Contributing

Should you have a suggestion or enhancement, please fork the repository and create a pull request. You also have the option to open an issue with the tag “enhancement”.

When submitting a pull request:

- Submit small pull requests that focus on a single change.
- Ensure that the documentation is current.

## License

Distributed under the MIT License. See <a href="/LICENSE">LICENSE</a> for more information.

## Pull Request Overview

This PR introduces two helper scripts designed to facilitate the extraction and listing of image files related to our data models:

- **`scripts/extract_models.sh`**: This script copies files matching the pattern `docs/data_models/*/images/*_model.gif` into the `images/` directory, prefixing each filename with its corresponding category for better organization.
  
- **`scripts/list_models_csv.sh`**: This script scans the repository for all `*_model.gif` files and generates a CSV file (`images/models_list.csv`) that lists these images, providing a quick reference for available models.

### Exclusion of Images

To prevent repository bloat, the actual image files have not been included in this PR. Instead, they can be added in a follow-up PR using Git LFS (Large File Storage) to manage large files efficiently. This approach ensures that our repository remains lightweight and manageable.

### How to Accept Changes

1. **Review the Scripts**: Check the changes made in the scripts to ensure they meet the project requirements.
2. **Run the Scripts**: You can run the scripts locally to verify their functionality:
   ```bash
   chmod +x scripts/extract_models.sh scripts/list_models_csv.sh
   ./scripts/extract_models.sh
   ./scripts/list_models_csv.sh
   ```
3. **Batch Commit Images**: If you need to add the images later, you can use the provided `scripts/batch_commit_images.sh` script to commit them in batches, ensuring that Git LFS is set up correctly.

### Running the Combined Script

To run the combined commit and PR script, use the following command:
```bash
chmod +x scripts/run_commit_and_pr.sh
./scripts/run_commit_and_pr.sh --branch workup --batch-size 200 --dir images
```
You can also use the `--auto-approve` flag to skip prompts during execution.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/jwoo92/database-answers.com.svg?style=for-the-badge
[contributors-url]: https://github.com/jwoo92/database-answers.com/graphs/contributors

[forks-shield]: https://img.shields.io/github/forks/jwoo92/database-answers.com.svg?style=for-the-badge
[forks-url]: https://github.com/jwoo92/database-answers.com/network/members

[stars-shield]: https://img.shields.io/github/stars/jwoo92/database-answers.com.svg?style=for-the-badge
[stars-url]: https://github.com/jwoo92/database-answers.com/stargazers

[issues-shield]: https://img.shields.io/github/issues/jwoo92/database-answers.com.svg?style=for-the-badge
[issues-url]: https://github.com/jwoo92/database-answers.com/issues

[license-shield]: https://img.shields.io/github/license/jwoo92/database-answers.com.svg?style=for-the-badge
[license-url]: https://github.com/jwoo92/database-answers.com/blob/master/LICENSE

[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/justin-woodward

[website-screenshot]: images/database-answers-screenshot.jpeg
