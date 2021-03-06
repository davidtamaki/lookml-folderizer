# LookML Folderizer

## Description
This bash script will create a folder for every distinct file type/extension found in the project, and put any such files inside a folder along with altering the `include` and `file` statements so that the project continues to function.

In the folder-land project, includes statements can be relative, or absolute paths, so given this non-folder situation:
```
- master.model.lkml
- foo.view.lkml
- bar.view.lkml
- hello_world.dashboard.lookml
```
This script will modify the project to this folder situation:
```
- models/
  - master.model.lkml
- views/
  - foo.view.lkml
  - bar.view.lkml
- dashboards/
  - hello_world.dashboard.lookml
```
In the pre-folder situation, master.model.lkml’s include statement would look like: `include: “*.view.lkml”`, but in the folderized world, it would need to be: `include: “/views/*.view.lkml”`. The full rules for includes folder-includes statements can be found [here](https://docs.looker.com/data-modeling/getting-started/ide-folders#using_include_with_ide_folders). 


## Minimum Requirements
- The project will need to be in [new LookML](https://discourse.looker.com/t/new-lookml-deep-dive-into-the-new-syntax-and-the-new-ide/3539)
- Include statements are defined in a single line, e.g.:
  - this will work:
    ```
    include: "pizza.view" # some comments here
    ```
  - this will not work:
    ```
    include:
    # some comments
    # here
    "pizza.view"
    ```

- Include statements require qualifying lkml file types with double quotes, e.g.:
  - these will work: `include: "pizza.view"` , `include: "pizza.view.lkml"`, `include: "pizza*.view"`
  - these will not work: `include: "pizza*"` , `include: pizza.view`


## Steps
1. Clone your git repo locally
2. Checkout your developer branch (make sure it's up-to-date with master)
3. Run this script. Use the directory of your git project as the 1st argument, e.g. `./lookml_folderization.sh /path/to/repo`
4. Commit the change and push to origin/developer branch
5. In Looker, Pull Remote Changes
6. Validate LookML in Project
7. Deploy to Production
