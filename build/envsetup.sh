function __print_pixeldust_functions_help() {
cat <<EOF
Additional PixelDust functions:
- cout:            Changes directory to out.
- repopick:        Utility to fetch changes from Gerrit.
- gerritremote:    Add git remote for PixelDust Gerrit Review.
- aospremote:      Add git remote for matching AOSP repository.
- cafremote:       Add git remote for matching CodeAurora repository.
- githubremote:    Add git remote for PixelDust Github.
- mka:             Builds using SCHED_BATCH on all processors.
- repolastsync:    Prints date and time of last repo sync.
EOF
}

function brunch()
{
    breakfast $*
    if [ $? -eq 0 ]; then
        mka bacon
    else
        echo "No such item in brunch menu. Try 'breakfast'"
        return 1
    fi
    return $?
}

function breakfast()
{
    target=$1
    local variant=$2
    unset LUNCH_MENU_CHOICES
    add_lunch_combo full-eng
    for f in `/bin/ls vendor/pixeldust/vendorsetup.sh 2> /dev/null`
        do
            echo "including $f"
            . $f
        done
    unset f

    if [ $# -eq 0 ]; then
        # No arguments, so let's have the full menu
        lunch
    else
        echo "z$target" | grep -q "-"
        if [ $? -eq 0 ]; then
            # A buildtype was specified, assume a full device name
            lunch $target
        else
            # This is probably just the pixeldust model name
            if [ -z "$variant" ]; then
                variant="userdebug"
            fi

            lunch pixeldust_$target-$variant
        fi
    fi
    return $?
}

alias bib=breakfast

function cout()
{
    if [  "$OUT" ]; then
        cd $OUT
    else
        echo "Couldn't locate out directory.  Try setting OUT."
    fi
}

function gerritremote()
{
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    git remote rm pixeldustgerrit 2> /dev/null
    local REMOTE=$(git config --get remote.pixeldust.projectname)
    local PIXELDUST="true"
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.pixeldust.projectname)
        PIXELDUST="false"
    fi
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.caf.projectname)
        PIXELDUST="false"
    fi

    if [ $PIXELDUST = "false" ]
    then
        local PROJECT=$(echo $REMOTE | sed -e "s#platform/#android/#g; s#/#_#g")
        local PFX="PIXELDUST/"
    else
        local PROJECT=$REMOTE
    fi

    local PIXELDUST_USER=$(git config --get review.gerrit.pixeldust.org.username)
    if [ -z "$PIXELDUST_USER" ]
    then
        git remote add pixeldustgerrit ssh://gerrit.pixeldust.org:29418/$PFX$PROJECT
    else
        git remote add pixeldustgerrit ssh://$PIXELDUST_USER@gerrit.pixeldust.org:29418/$PFX$PROJECT
    fi
    echo "Remote 'pixeldustgerrit' created"
}

function aospremote()
{
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    git remote rm aosp 2> /dev/null
    local PROJECT=$(pwd -P | sed -e "s#$ANDROID_BUILD_TOP\/##; s#-caf.*##; s#\/default##")
    # Google moved the repo location in Oreo
    if [ $PROJECT = "build/make" ]
    then
        PROJECT="build"
    fi
    if (echo $PROJECT | grep -qv "^device")
    then
        local PFX="platform/"
    fi
    git remote add aosp https://android.googlesource.com/$PFX$PROJECT
    echo "Remote 'aosp' created"
}

function cafremote()
{
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    git remote rm caf 2> /dev/null
    local PROJECT=$(pwd -P | sed -e "s#$ANDROID_BUILD_TOP\/##; s#-caf.*##; s#\/default##")
     # Google moved the repo location in Oreo
    if [ $PROJECT = "build/make" ]
    then
        PROJECT="build"
    fi
    if [[ $PROJECT =~ "qcom/opensource" ]];
    then
        PROJECT=$(echo $PROJECT | sed -e "s#qcom\/opensource#qcom-opensource#")
    fi
    if (echo $PROJECT | grep -qv "^device")
    then
        local PFX="platform/"
    fi
    git remote add caf https://source.codeaurora.org/quic/la/$PFX$PROJECT
    echo "Remote 'caf' created"
}

function githubremote()
{
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    git remote rm pixeldust 2> /dev/null
    local REMOTE=$(git config --get remote.caf.projectname)

    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.pixeldust.projectname)
    fi

    local PROJECT=$(echo $REMOTE | sed -e "s#platform/#android/#g; s#/#_#g")

    if [[ $PROJECT =~ "qcom-opensource" ]];
    then
        PROJECT=$(echo $PROJECT | sed -e "s#qcom-opensource#qcom_opensource#")
    fi

    git remote add pixeldust https://github.com/pixeldust-project-caf/$PROJECT
    echo "Remote 'pixeldust' created"
}

# Make using all available CPUs
function mka() {
    if [ -f $ANDROID_BUILD_TOP/$QTI_BUILDTOOLS_DIR/build/update-vendor-hal-makefiles.sh ]; then
        vendor_hal_script=$ANDROID_BUILD_TOP/$QTI_BUILDTOOLS_DIR/build/update-vendor-hal-makefiles.sh
        source $vendor_hal_script --check
        regen_needed=$?
    else
        vendor_hal_script=$ANDROID_BUILD_TOP/device/qcom/common/vendor_hal_makefile_generator.sh
        regen_needed=1
    fi

    if [ $regen_needed -eq 1 ]; then
        _wrap_build $(get_make_command hidl-gen) hidl-gen ALLOW_MISSING_DEPENDENCIES=true
        RET=$?
        if [ $RET -ne 0 ]; then
            echo -n "${color_failed}#### hidl-gen compilation failed, check above errors"
            echo " ####${color_reset}"
            return $RET
        fi
        source $vendor_hal_script
        RET=$?
        if [ $RET -ne 0 ]; then
            echo -n "${color_failed}#### HAL file .bp generation failed dure to incpomaptible HAL files , please check above error log"
            echo " ####${color_reset}"
            return $RET
        fi
    fi

    m -j "$@"
}

function repolastsync() {
    RLSPATH="$ANDROID_BUILD_TOP/.repo/.repo_fetchtimes.json"
    RLSLOCAL=$(date -d "$(stat -c %z $RLSPATH)" +"%e %b %Y, %T %Z")
    RLSUTC=$(date -d "$(stat -c %z $RLSPATH)" -u +"%e %b %Y, %T %Z")
    echo "Last repo sync: $RLSLOCAL / $RLSUTC"
}

function repopick()
{
    T=$(gettop)
    $T/vendor/pixeldust/build/tools/repopick.py $@
}

# Android specific JACK args
if [ -n "$JACK_SERVER_VM_ARGUMENTS" ] && [ -z "$ANDROID_JACK_VM_ARGS" ]; then
    export ANDROID_JACK_VM_ARGS=$JACK_SERVER_VM_ARGUMENTS
fi

# Enable SD-LLVM if available
if [ -d $(gettop)/vendor/qcom/sdclang-8.0/linux-x86 ]; then
    case `uname -s` in
        Darwin)
            # Darwin is not supported yet
            ;;
        *)
            export SDCLANG=true
            export SDCLANG_PATH=$(gettop)/vendor/qcom/sdclang-8.0/linux-x86/bin
            export SDCLANG_PATH_2=$(gettop)/vendor/qcom/sdclang-8.0/linux-x86/bin
            export SDCLANG_FLAGS=
            export SDCLANG_FLAGS_2=
            ;;
    esac
fi
