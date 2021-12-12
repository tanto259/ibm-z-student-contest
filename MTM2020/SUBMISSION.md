### Submission Details

Below are the submission details, posted with no non-cosmetic edits.

#### Title

jobs.py

#### Notes

A Python script to be executed from your PC which allows you to list jobs (while allowing you to specify the prefix and job owner), restart jobs and cancel them! It is powered by z/OSMF REST APIs and require Python 3 to run. As a beta feature, the script can also accept client certificates as replacement for user/password authentication, allowing those of you with stricter security to run it too!

#### Flyer

![flyer](https://user-images.githubusercontent.com/13640520/145719103-bfa9b461-aa9d-4def-9ab9-d594151e060f.png)

#### Directions

Scan the QR code from the flyer or go to https://gist.github.com/tanto259/d24fa0fcafff8964c8332c63383c3dcb and download the script! If you are using MTM, you are good to go, otherwise you might want to edit your hostname near the top of the script :) So, assuming you have Python 3 installed, you can execute the various features with `python3 jobs.py`.

There are 3 available functions: list, restart and cancel. List requires you to specify a user parameter, while prefix (default = *) and owner (default = same as user) are optional. While for restart and cancel: user, jobid and jobname are all required.

Examples includes `python3 jobs.py list --user IBMUSER --owner Z00686`, `python3 jobs.py restart --user z00686 --jobid JOB05368 --jobname ADD1JCL` and `python3 jobs.py cancel --user z00686 --jobid JOB05368 --jobname ADD1JCL`.

More details available if you execute `python3 jobs.py`.

For the sysprogs among us, z/OSMF must be enabled and running for this to run. To enable additional features such as validation for server certificates and client side certificate authentication, check the lines near the top of the script :)