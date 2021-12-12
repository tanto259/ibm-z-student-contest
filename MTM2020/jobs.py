######################################################################
### jobs.py - job utilities from your z/OS using Python and z/OSMF ###
### Made for MTM 2020 Grand Challenge                              ###
### by Hartanto Ario Widjaya                                       ###
### https://www.linkedin.com/in/hartantoariowidjaya                ###
######################################################################

import sys
import getopt
import base64
import getpass
import requests
import json
import warnings
warnings.filterwarnings('ignore')

# You may edit this to include your own hostname. Please omit the https:// part.
# Make sure that z/OSMF is active. Generally speaking if you can use Zowe, you should be able to use this.
hostname = "192.86.32.153:10443"
# This includes an beta support for certificate authentication.
# To do so, please replace the below auth variable with the full path of your client certificate.
auth = "pass"
# This allows the system to accept self-signed certificate.
# To disallow, replace the below selfSigned variable with False
selfSigned = True
# Guide: https://www.ibm.com/support/knowledgecenter/SSLTBW_2.4.0/com.ibm.zos.v2r4.izua700/IZUHPINFO_RESTServices.htm

# ------
# The section belows contains defined functions which are used repeatedly in this program

def listHead():
    print("Usage: python3 jobs.py list --user <your-user-id> --owner <user-id-to-search> --prefix <prefix-to-search>")
    print("Only --user is required. Both --search and --prefix are optional.")
    print("Example: ") 
    print("1. python3 jobs.py list --user IBMUSER --owner Z00686 - login as IBMUSER to see Z00686's jobs")
    print("2. python3 jobs.py list --user Z00686 - login as Z00686 to see their own jobs")

def restartHead():
    print("Usage: python3 jobs.py restart --user <your-user-id> --jobid <jobid-to-restart> --jobname <jobname-to-restart>")
    print("All parameters: --user, --search and --prefix are required.")
    print("Example: ") 
    print("python3 jobs.py restart --user IBMUSER --jobid JOB00012 --jobname ADD1JCL")

def cancelHead():
    print("Usage: python3 jobs.py cancel --user <your-user-id> --jobid <jobid-to-cancel> --jobname <jobname-to-cancel>")
    print("All parameters: --user, --search and --prefix are required.")
    print("Example: ") 
    print("python3 jobs.py cancel --user IBMUSER --jobid JOB00012 --jobname ADD1JCL")

def header():
    print()
    print("jobs.py - check your job status and resubmit jobs for your z/OS system")
    print("Made by Hartanto Ario Widjaya")
    print()
    print("A. list - list the jobs")
    listHead()
    print()
    print("B. restart - restart the job")
    restartHead()
    print()
    print("C. cancel - cancel the job")
    cancelHead()
    print()
    sys.exit(0)

# The codes below define the requests query. X-CSRF-ZOSMF-HEADER is included for CORS request with Z/OSMF.

def getRequest(url, auth, user, pword):
    if auth == "pass":
        if selfSigned:
            response = requests.get(
                url, headers={'X-CSRF-ZOSMF-HEADER': 'zosmf'}, auth=(user, pword), verify=False
            )
        else:
            response = requests.get(
                url, headers={'X-CSRF-ZOSMF-HEADER': 'zosmf'}, auth=(user, pword)
            )
    else:
        if selfSigned:
            response = requests.get(
                url, headers={'X-CSRF-ZOSMF-HEADER': 'zosmf'}, cert=auth, verify=False
            )
        else:
            response = requests.get(
                url, headers={'X-CSRF-ZOSMF-HEADER': 'zosmf'}, cert=auth
            )
    return response

def putRequest(url, auth, user, pword, payload, media):
    if auth == "pass":
        if selfSigned:
            response = requests.put(
                url, headers={'X-CSRF-ZOSMF-HEADER': 'zosmf', 'Content-Type': media}, auth=(user, pword), verify=False, data=payload
            )
        else:
            response = requests.put(
                url, headers={'X-CSRF-ZOSMF-HEADER': 'zosmf', 'Content-Type': media}, auth=(user, pword), data=payload
            )
    else:
        if selfSigned:
            response = requests.put(
                url, headers={'X-CSRF-ZOSMF-HEADER': 'zosmf', 'Content-Type': media}, cert=auth, verify=False, data=payload
            )
        else:
            response = requests.put(
                url, headers={'X-CSRF-ZOSMF-HEADER': 'zosmf', 'Content-Type': media}, cert=auth, data=payload
            )
    return response

# ------
# The section below contain the main logic of the program

if len(sys.argv) <= 1:
    header()

if sys.argv[1] == "list":

    # List Job requests are passed here.

    user = "invalidQuery"
    search = "invalidQuery"
    prefix = "invalidQuery"

    # Get the command line argument being passed in.

    try: 
        opts, args = getopt.getopt(sys.argv[2:] , "u:o:p:", ["user =", "owner =", "prefix ="]) 
    except: 
        listHead()
        sys.exit(1)
    else:
        for opt, arg in opts: 
            if opt in ['-u', '--user ']: 
                user = arg 
            elif opt in ['-o', '--owner ']: 
                search = arg
            elif opt in ['-p', '--prefix ']: 
                prefix = arg
        if not opts:
            listHead()
            sys.exit(0)

    # Check that the user argument is being changed. For the other two, change it to default.

    if user == "invalidQuery":
        print("ERROR: The --user argument is required.")
        sys.exit(1)

    if search == "invalidQuery":
        search = user

    if prefix == "invalidQuery":
        prefix = "*"

    # Validate the length of the parameters.

    if (len(user) > 8 or len(search) > 8 or len(prefix) > 8):
        print("ERROR: Invalid Parameter Length. Prefix and User ID can only be up to 8 characters long.")
        sys.exit(1)

    # Attempt to get password is password validation is set.

    try:
        if auth == "pass": 
            pword = getpass.getpass("Enter password for %s: " % user) 
    except: 
        print("ERROR: Exception in Input Password") 
    else: 

        # Submit a GET request to the corresponding URL
        # https://www.ibm.com/support/knowledgecenter/SSLTBW_2.4.0/com.ibm.zos.v2r4.izua700/IZUHPINFO_API_GetListJobs.htm

        url = "https://" + hostname + "/zosmf/restjobs/jobs?owner=" + search + "&prefix=" + prefix

        response = getRequest(url, auth, user, pword)

        if response.status_code == 401:
            print("ERROR: Unauthorized. Please check that your user ID and password is correct.")
            sys.exit(1)

        jdata = response.json()

        print()
        print("Job Listing for " + search)
        print()

        for data in jdata:
            print(data["jobname"] + " (" + data["jobid"] + ") - " + data["retcode"])

elif sys.argv[1] == "restart" or sys.argv[1] == "cancel":

    # Submit and Cancel Job requests are passed here.
    
    user = "invalidQuery"
    jobid = "invalidQuery"
    jobname = "invalidQuery"

    # Get the command line argument being passed in.

    try: 
        opts, args = getopt.getopt(sys.argv[2:] , "u:i:n:", ["user =", "jobid =", "jobname ="]) 
    except: 
        if sys.argv[1] == "restart":
            restartHead()
        else:
            cancelHead()
        sys.exit(1)
    else:
        for opt, arg in opts: 
            if opt in ['-u', '--user ']: 
                user = arg 
            elif opt in ['-i', '--jobid ']: 
                jobid = arg
            elif opt in ['-n', '--jobname ']: 
                jobname = arg
        if not opts:
            if sys.argv[1] == "restart":
                restartHead()
            else:
                cancelHead()
            sys.exit(0)

    # If there is no changes, return error to the user, forcing them to specify each parameter.

    if user == "invalidQuery":
        print("ERROR: The --user argument is required.")
        sys.exit(1)

    if jobid == "invalidQuery":
        print("ERROR: The --jobid argument is required.")
        sys.exit(1)

    if jobname == "invalidQuery":
        print("ERROR: The --jobname argument is required.")
        sys.exit(1)

    # Length validation

    if (len(user) > 8 or len(jobid) > 8 or len(jobname) > 8):
        print("ERROR: Invalid Parameter Length. User ID, Job ID and Job Name can only be up to 8 characters long.")
        sys.exit(1)

    # Attempt to get password is password validation is set.

    try:
        if auth == "pass": 
            pword = getpass.getpass("Enter password for %s: " % user) 
    except: 
        print("ERROR: Exception in Input Password") 
    else:
        if sys.argv[1] == "cancel":

            # Submit a PUT request to the URL with the corresponding payload
            # https://www.ibm.com/support/knowledgecenter/SSLTBW_2.4.0/com.ibm.zos.v2r4.izua700/IZUHPINFO_API_PutCancelJob.htm

            url = "https://" + hostname + "/zosmf/restjobs/jobs/" + jobname + "/" + jobid

            payload = '{"request": "cancel"}'

            response = putRequest(url, auth, user, pword, payload, "application/json")

            if response.status_code == 401:
                print("ERROR: Unauthorized. Please check that your user ID and password is correct.")
                sys.exit(1)

            jdata = response.json()

            if response.status_code == 200:
                print()
                print("Job Cancelled Successfully!")
                sys.exit(0)
            else:
                print()
                print("ERROR: Unable to cancel job.")
                print("Return Code : " + str(jdata["rc"]))
                print("Message     : " + jdata["message"])
                sys.exit(1)

        else:

            # Submit a GET request to get the original JCL
            # https://www.ibm.com/support/knowledgecenter/SSLTBW_2.4.0/com.ibm.zos.v2r4.izua700/IZUHPINFO_API_RetrieveSpoolFileContents.htm

            url = "https://" + hostname + "/zosmf/restjobs/jobs/" + jobname + "/" + jobid + "/files/JCL/records"

            response = getRequest(url, auth, user, pword)

            if response.status_code == 401:
                print("ERROR: Unauthorized. Please check that your user ID and password is correct.")
                sys.exit(1)

            jcl = response.text

            # Submit a PUT request with the JCL as a payload
            # https://www.ibm.com/support/knowledgecenter/SSLTBW_2.4.0/com.ibm.zos.v2r4.izua700/IZUHPINFO_API_PutSubmitJob.htm

            url = "https://" + hostname + "/zosmf/restjobs/jobs/"

            response = putRequest(url, auth, user, pword, jcl, "text/plain")

            if response.status_code == 401:
                print("ERROR: Unauthorized. Please check that your user ID and password is correct.")
                sys.exit(1)

            jdata = response.json()

            if 'jobid' not in jdata:
                print()
                print("ERROR: Unable to submit job.")
                print("Return Code : " + str(jdata["rc"]))
                print("Message     : " + jdata["message"])
                sys.exit(1)
            else:
                print()
                print("Job Submitted Successfully!")
                print("Job ID: " + jdata["jobid"] + " Name: " + jdata["jobname"])
                sys.exit(0)

else:
    header()