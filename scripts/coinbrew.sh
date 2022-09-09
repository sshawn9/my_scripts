#!/usr/bin/env bash

# Author: Ted Ralphs (ted@lehigh.edu)
# Copyright 2016-2019, Ted Ralphs
# Released Under the Eclipse Public License 
#
# TODO
# - fix dependency-tracking or remove it from configure
# - Add option to update all current checkouts (like fetch, but no version checks) 
# - Read config.site
# - Make it possible to build a series of projects
# - Provide an option to build Python extensions
# - Provide an option to download dependencies in binary format (this is started)
# - Make autostash work better https://stackoverflow.com/questions/53049088/can-git-remind-me-about-or-auto-apply-a-stash-when-switching-back-into-the-corre/53050054

# script debugging
#set -x
#PS4='${LINENO}:${PWD}: '

###################################################################################
# First, we have a bunch of helper functions.
# The main script starts after all the function definitions.
###################################################################################

function help {

    echo "Usage: coinbrew <command> <name|URL@version> --option value ..."
    echo "       Run without arguments for interactive mode"
    echo
    echo "Commands:"
    echo
    echo "  fetch: Clone repos of project and dependencies"
    echo "    options: --ssh checkout git projects using ssh protocol rather than https"
    echo "             --skip,-s <'proj1 proj2'> skip listed projects"
    echo "             --no-third-party don't fetch third party source (run getter-scripts)"
    echo "             --skip-update skip updating projects that are already checked out (useful if you have local changes)"
    echo "             --skip-dependencies don't fetch dependencies, only main project"
    echo "             --latest-release Fetch latest releases of projects"
    echo "             --time check out project and all dependencies at a time stamp"
    echo "             --auto-stash stash changes before switching versions (experimental)"
    echo "             --no-rebase Pull without rebase (default is with rebase)"
    echo
    echo "  build: Configure, build, test (optional), and install all projects"
    echo "    options: --configure-help (print help on build configuration"
    echo "             --xxx=yyy (will be passed through to configure)"
    echo "             VAR=xxx (will be passed through to configure)"
    echo "             --parallel-jobs,-j <n> build in parallel with maximum 'n' jobs (default: 1)"
    echo "             --build-dir,-b </dir/to/build/in> where to build (default: $PWD/build)"
    echo "             --tests,-t <all|main|none> which tests to do before install (default: all)"
    echo "             --verbosity,-v <1-4> set verbosity level (default: 1)"
    echo "             --reconfigure re-run configure"
    echo "             --prefix,-p </dir/to/install> where to install (default: $PWD/dist)"
    echo "             --skip-dependencies don't build dependencies, only main project"
    echo "             --no-third-party don't build third party projects"
    echo "             --off-line build in offline mode (no network access)"
    echo "             --static build static executables on Linux and OS X" 
    echo "             --download-binary <'proj1 proj2'> list of binary packages to download"
    echo "             --platform <string> string specifying platform (required for binaries)"
    echo
    echo "  install: Install all projects in location specified by prefix. This is done"
    echo "           done automatically after build, so probably not useful in general." 
    echo
    echo "  uninstall: Uninstall all projects"
    echo
    echo "  download: Download project binaries (experimental, limited projects supported)"
    echo "    options: --platform <string> string specifying platform (required for binaries)"
    echo "             --prefix,-p </dir/to/install> where to install (default: $PWD/dist)"
    echo 
    echo "General options:"
    echo "  --debug,-d Turn on debugging output (this should be the first option specified)"
    echo "  --no-prompt,-n Suppress interactive prompts"
    echo "  --help,-h Print help"
    echo 

}

###################################################################################
# Helpers to switch directories 
###################################################################################

function pushd_ {

    pushd $1 > /dev/null

}

function popd_ {

    popd > /dev/null

}

###################################################################################
# Helper to print status messages 
###################################################################################

function print_action {
    echo
    echo "##################################################"
    echo "### $1 "
    echo "##################################################"
    echo
}

###################################################################################
# Parse command-line arguments to the script
###################################################################################

function parse_args {

    while (( "$#" ))
    do
        arg=$1
        shift
        legacy_format=false
        case $arg in
            *=*)
                option=${arg%%=*}
                option_arg=${arg#*=}
                legacy_format=true
                ;;
            -*)
                option=$arg
                if [ "$#" = 0 ]; then
                    option_arg=
                else
                    if [[ "$1" == -* ]]; then
                        option_arg=
                    else
                        option_arg=$1
                    fi
                fi
                ;;
            *)
                option=$arg
                option_arg=
                ;;
        esac
        case $option in
            -p|--prefix)
                if [ x"$option_arg" != x ]; then
                    case $option_arg in
                        [\\/$]* | ?:[\\/]* | NONE | '' )
                            prefix=$option_arg
                            ;;
                        *)  
                            prefix=$PWD/$option_arg
                            ;;
                    esac
                    if [ $legacy_format = false ]; then
                        shift
                    fi
                elif [ x"$build_dir" != x ]; then
                    case $build_dir in
                        [\\/$]* | ?:[\\/]* | NONE | '' )
                            prefix=$build_dir
                            ;;
                        *)
                            prefix=$PWD/$build_dir
                            ;;
                    esac
                else
                    die "Error: ${RED}No path provided for --prefix${NOFORMAT}" 3
                fi
                ;;
            -b|--build-dir)
                if [ x"$option_arg" != x ]; then
                    case $option_arg in
                        [\\/$]* | ?:[\\/]* | NONE | '' )
                            build_dir=$option_arg
                            ;;
                        *)
                            build_dir=$PWD/$option_arg
                            ;;
                    esac
                else
                    die "Error: ${RED}No path provided for --build-dir${NOFORMAT}" 3
                fi
                if [ $legacy_format = false ]; then
                    shift
                fi
                ;;
            -j|--parallel-jobs)
                if [ x"$option_arg" != x ]; then
                    jobs=$option_arg
                else
                    die "Error: ${RED}No number specified for --parallel-jobs${NOFORMAT}" 3
                fi
                if [ $legacy_format = false ]; then
                    shift
                fi
                ;;
            --threads)
                msg "Error: ${RED}The 'threads' argument has been re-named 'parallel-jobs'."
                msg "Please re-run with correct argument name"
                die "${NOFORMAT}Exiting." 3
                ;;
            -v|--verbosity)
                if [ x"$option_arg" != x ]; then
                    verbosity=$option_arg
                else
                    die "Error: ${RED}No verbosity specified for --verbosity${NOFORMAT}" 3
                fi
                if [ $legacy_format = false ]; then
                    shift
                fi
                ;;
            --main-proj)
                if [ x"$option_arg" != x ]; then
                    main_proj=$option_arg
                else
                    die "Error: ${RED}No main project specified for --main-proj.${NOFORMAT}" 3
                fi
                if [ $legacy_format = false ]; then
                    shift
                fi
                ;;
            --main-proj-version)
                if [ x"$option_arg" != x ]; then
                    main_proj_version=$option_arg
                else
                    die "Error: ${RED}No main project version specified for --main-proj-version.${NOFORMAT}" 3
                fi
                if [ $legacy_format = false ]; then
                    shift
                fi
                ;;
            --main-proj-sha)
                if [ x"$option_arg" != x ]; then
                    main_proj_sha=$option_arg
                else
                    die "Error: ${RED}No main project specified for --main-proj-sha.${NOFORMAT}" 3
                fi
                if [ $legacy_format = false ]; then
                    shift
                fi
                ;;                
            -s|--skip)
                if [ x"$option_arg" != x ]; then
                    coin_skip_projects=$option_arg
                else
                    die "Error: ${RED}No projects specified with --skip.${NOFORMAT}" 3
                fi
                if [ $legacy_format = false ]; then
                    shift
                fi
                ;;
            --time)
                if [ x"$option_arg" != x ]; then
                    checkout_time=$option_arg
                else
                    die "No checkout time specified with --time.${NOFORMAT}" 3
                fi
                if [ $legacy_format = false ]; then
                    shift
                fi
                ;;
            -t|--tests)
                if [ x"$option_arg" != x ]; then
                    run_tests=$option_arg
                else
                    die "Error: ${RED}No argument specified with --tests.${NOFORMAT}" 3
                fi
                if [ $legacy_format = false ]; then
                    shift
                fi
                ;;
            --download-binary)
                if [ x"$option_arg" != x ]; then
                    download_projs=$option_arg
                    download=true
                else
                    die "Error: ${RED}No argument specified with --download-binary${NOFORMAT}" 3
                fi
                if [ $legacy_format = false ]; then
                    shift
                fi
                ;;
            --platform)
                if [ x"$option_arg" != x ]; then
                    platform=$option_arg
                else
                    die "Error: ${RED}No argument specified with --platform${NOFORMAT}" 3
                fi
                if [ $legacy_format = false ]; then
                    shift
                fi
                ;;
            --enable-msvc)
                configure_options["$arg"]=""
                disable_uninstalled=false
                ;;
            --disable-pkg-config)
                configure_options["$arg"]=""
                disable_uninstalled=false
                ;;
            --enable-debug)
                configure_options["$arg"]=""
                enable_debug=true
                ;;
            --static)
                configure_options["--disable-shared"]=""
                configure_options["LT_LDFLAGS=-all-static"]=""
                configure_options["LDFLAGS=-static"]=""
                ;;
            -h|--help)
                help
                die "" 0
                ;;
            --test)
                run_tests=main
                ;;
            --test-all)
                run_tests=all
                ;;
            -c|--configure-help)
                configure_help=true
                no_prompt=true
                ;;
            --skip-dependencies)
                skip_dependencies=true
                ;;
            --sparse)
                sparse=true
                ;;
            --ssh)
                ssh_checkout=true
                ;;
            -d|--debug)
                set -x
                ;;
            --rebuild)
                rebuild=true
                ;;
            --reconfigure)
                reconfigure=true
                ;;
            --no-third-party)
                get_third_party=false
                ;;
            -n|--no-prompt)
                no_prompt=true
                ;;
            --skip-update)
                skip_update=true
                ;;
            --auto-stash)
                auto_stash=true
                ;;
            --latest-release)
                get_latest_release=true
                ;;
            --no-rebase)
                rebase=false
                ;;
            --no-color)
                use_color=false
                ;;
            --enable-optional)
                get_optional=true
                ;;
            --disable-recommended)
                get_recommended=false
                ;;
            --no-yaml)
                read_yaml=false
                ;;
            yaml)
                num_actions+=1
                write_yaml=true
                ;;
            --off-line)
                offline=true
                ;;
            fetch)
                num_actions+=1
                fetch=true
                ;;
            build)
                num_actions+=1
                build=true
                ;;
            install)
                num_actions+=1
                install=true
                ;;
            uninstall)
                num_actions+=1
                uninstall=true
                ;;
            download)
                num_actions+=1
                download=true
                ;;
            *)
                # Look for things that seem to be arguments for configure
                if [[ "$arg" == *=* ]] || [[ "$arg" == --* ]]; then
                    configure_options["$arg"]=""
                else

	            slug=$(echo $arg | sed 's|https://github.com/||' | sed 's|git@github.com:||')

                    #Now look for the version number after the last ":" or "@"
                    #We support both formats for now. If there is any "@", then
                    #the format is the one with version after "@", otherwise, it
                    #is the version with ":"
                    if [[ $slug == *@* ]]; then
                        main_proj=${arg%@*}
                        main_proj_version=${arg##*@}
                    elif [[ $slug == *:* ]]; then
                        main_proj=${arg%:*}
                        main_proj_version=${arg##*:}
                        echo "Warning: specifying version after ':' is deprecated and will be removed in a future version. Use '@'."
                    else
                        main_proj=$arg
                    fi
                    if [ $(echo $main_proj_version | awk -F"/" "{print NF}") = "1" ]; then
                        if [ $(echo $main_proj_version | awk -F"." "{print NF}") = "2" ]; then
                           main_proj_version="stable/$main_proj_version"
                        elif [ $(echo $main_proj_version | awk -F"." "{print NF}") = "3" ]; then
                           main_proj_version="releases/$main_proj_version"
                        fi
                    fi
                    if [ "$main_proj_version" = "current" ]; then
                        keep_current=true
                    fi
		fi
                ;;
        esac
    done

}

###################################################################################
# Add functions for parsing YAML files
# https://github.com/jasperes/bash-yaml
###################################################################################

parse_yaml() {
    local yaml_file=$1
    local prefix=
    local s
    local w
    local fs

    s='[[:space:]]*'
    w='[a-zA-Z0-9_.-]*'
    fs="$(echo @|tr @ '\034')"

    (
        sed -e '/- [^\“]'"[^\']"'.*: /s|\([ ]*\)- \([[:space:]]*\)|\1-\'$'\n''  \1\2|g' |

        sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
            -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
            -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
            -e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |

        awk -F"$fs" '{
            indent = length($1)/2;
            if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
            vname[indent] = $2;
            for (i in vname) {if (i > indent) {delete vname[i]}}
                if (length($3) > 0) {
                    vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
                    printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1],$3);
                }
            }' |

        sed -e 's/_=/+=/g' |

        awk 'BEGIN {
                FS="=";
                OFS="="
            }
            /(-|\.).*=/ {
                gsub("-|\\.", "_", $1)
            }
            { print }'
    ) < "$yaml_file"
}

create_variables() {
    local yaml_file="$1"
    eval "$(parse_yaml "$yaml_file")"
}

###################################################################################
# Find out if we're supposed to skip any projects
###################################################################################

function find_skip_projects {
    
    for c in ${!configure_options[@]} ; do
    if [[ $c == --without-* ]]; then
        found_project=true
        proj_name=$(echo "$c" | cut -d '-' -f 4)
        proj_name=${proj_name,,}
        case $proj_name in
            asl)
                proj_dir="ThirdParty/ASL"
                ;;
            blas)
                proj_dir="ThirdParty/Blas"
                ;;
            filtersqp)
                proj_dir="ThirdParty/FilterSQP"
                ;;
            glpk)
                proj_dir="ThirdParty/Glpk"
                ;;
            hsl)
                proj_dir="ThirdParty/HSL"
                ;;
            lapack)
                proj_dir="ThirdParty/Lapack"
                ;;
            metis)
                proj_dir="ThirdParty/Metis"
                ;;
            mumps)
                proj_dir="ThirdParty/Mumps"
                ;;
            scip)
                proj_dir="ThirdParty/SCIP"
                ;;
            alps)
                proj_dir="Alps"
                ;;
            bcp)
                proj_dir="Bcp"
                ;;
            bcps)
                proj_dir="Bcps"
                ;;
            blis)
                proj_dir="Blis"
                ;;
            bonmin)
                proj_dir="Bonmin"
                ;;
            cbc)
                proj_dir="Cbc"
                ;;
            cgl)
                proj_dir="Cgl"
                ;;
            clp)
                proj_dir="Clp"
                ;;
            coinmp)
                proj_dir="CoinMP"
                ;;
            coinutils)
                proj_dir="CoinUtils"
                ;;
            couenne)
                proj_dir="Couenne"
                ;;
            dip)
                proj_dir="Dip"
                ;;
            disco)
                proj_dir="DisCO"
                ;;
            dylp)
                proj_dir="DyLP"
                ;;
            flopcpp)
                proj_dir="FlopCpp"
                ;;
            ipopt)
                proj_dir="Ipopt"
                ;;
            mibs)
                proj_dir="MibS"
                ;;
            os)
                proj_dir="OS"
                ;;
            osi)
                proj_dir="Osi"
                ;;
            symphony)
                proj_dir="SYMPHONY"
                ;;
            smi)
                proj_dir="Smi"
                ;;
            vol)
                proj_dir="Vol"
                ;;
            cppad)
                proj_dir="cppad"
                ;;
            amd|cholmod)
                found_project=false
                ;;
            *)
                echo "Warning: Unknown project $proj_name"
                found_project=false
                ;;
        esac
        if [ $found_project = "true" ]; then
            coin_skip_projects="${coin_skip_projects:-} $proj_dir"
        fi
    fi
done

}

###################################################################################
# Determine whether we're supposed to build the project
###################################################################################

function should_build {

    TMP_IFS=$IFS
    unset IFS
    for i in $coin_skip_projects
    do
        if [ $1 = $i ]; then
            IFS=$TMP_IFS
            print_action "Skipping $dir"
            return 1
        fi
    done
    if [ $(echo $dir | cut -d '/' -f 1) = ThirdParty ]; then
        if [ $(echo $dir | cut -d '/' -f 2) = HSL ]; then
            if [ ! -f $dir/coinhsl/common/deps.f ]; then
                IFS=$TMP_IFS
                print_action "Skipping $dir"
                return 1
            fi
        elif ([ -e $dir ] && [ ! -e $dir/.build ]) ||
           [ $get_third_party = false ]; then
            IFS=$TMP_IFS
            print_action "Skipping $dir"
            return 1
        fi
    fi
    IFS=$TMP_IFS

    case $required in
        *ecommended)
            if [ $get_recommended = true ]; then
                return 0
            else
                print_action "Skipping $dir (--disable-recommended was specified)"
                return 1
            fi
            ;;
        *ptional)
            if [ $get_optional = true ]; then
                return 0
            else
                print_action "Skipping $dir (--enable-optional to build)"
                return 1
            fi
            ;;
        *)
            return 0
            ;;
    esac
}

###################################################################################
# Determine whether we're supposed to fetch the project
###################################################################################

function should_fetch {

    if [ -d $dir ] && ([ $skip_update = true ] || [ $fetch != true ]); then
        return 1
    fi
       
    TMP_IFS=$IFS
    unset IFS
    for i in $coin_skip_projects
    do
        if [ $dir = $i ]; then
            IFS=$TMP_IFS
            return 1
        fi
    done
    IFS=$TMP_IFS

    return 0
}

###################################################################################
# Determine the version currently checked out in a git repo
###################################################################################

function get_version_git {

    current_rev=$(git rev-parse HEAD)
    if [[ "$(git show-ref --tags | fgrep $current_rev)" == *releases* ]]; then
	git show-ref --tags | fgrep $current_rev | fgrep releases | cut -d '/' -f 4
    elif [[ "$(git ls-remote --tags | fgrep $current_rev)" == *releases* ]]; then
	git ls-remote --tags | fgrep $current_rev | fgrep releases | \
            cut -d '/' -f 4 | cut -d '^' -f 1
    elif [[ "$(git show-ref --heads | fgrep $current_rev)" == *stable* ]]; then
	git show-ref --heads | fgrep $current_rev | fgrep stable | cut -d '/' -f 4
    elif [ "$(git show-ref --heads | fgrep $current_rev)" != "" ]; then
        # If more than one version matches, just take the last
	git show-ref --heads | fgrep $current_rev | cut -d '/' -f 3 | tail -1
    else
        echo $current_rev
    fi

}

###################################################################################
# Determine version from an SVN URL (there are still some SVN URLs in Dependencies)
###################################################################################

function get_version_svn {

    if [ $proj = "BuildTools" ] &&
           [ $(echo $1 | cut -d '/' -f 6) = 'ThirdParty' ]; then
        if [ $(echo $1 | cut -d '/' -f 8) = trunk ]; then
            echo "trunk"
        else
            echo $1 | cut -d '/' -f 8-9
        fi
    elif [ $proj = "CHiPPS" ]; then
        if [ $(echo $1 | cut -d '/' -f 7) = trunk ]; then
            echo "trunk"
        else
            echo $1 | cut -d '/' -f 7-8
        fi
    elif [ $proj = "Data" ]; then
        if [ $(echo $1 | cut -d '/' -f 7) = trunk ]; then
            echo "trunk"
        else
            echo $1 | cut -d '/' -f 7-8
        fi
    elif [ $proj = "CoinBazaar" ]; then
        if [ $(echo $1 | cut -d '/' -f 9) = trunk ]; then
            echo "trunk"
        else
            echo $1 | cut -d '/' -f 8-9
        fi
    else
        if [ $(echo $1 | cut -d '/' -f 6) = trunk ]; then
            echo "trunk"
        else
            echo $1 | cut -d '/' -f 6-7
        fi
    fi

}

###################################################################################
# Convert an SVN URL to a git URL
###################################################################################

function svn2git {

    # Convert SVN URL to a Github one and check out with git
    if [ $proj = "BuildTools" ] || [ $proj = "Data" ]; then
        new_url=$url_prefix"-tools/"
    elif [ $proj = "CoinBazaar" ]; then
        new_url=$url_prefix"-bazaar/"
    else
        new_url=$url_prefix"/"
    fi
    if [ $(echo $dir | cut -d "/" -f 1) = "ThirdParty" ]; then
        new_url+=$(echo $dir | sed s"|/|-|")
    elif [ $proj = "Data" ]; then
        new_url+=$(echo $dir | sed s"|/|-|")
    elif [ $proj = "CHiPPS" ]; then
        if [ $dir = "Alps" ]; then
            new_url+="CHiPPS-ALPS"
        elif [ $dir = "Bcps" ]; then
            new_url+="CHiPPS-BiCePS"
        else
            new_url+="CHiPPS-BLIS"
        fi
    elif [ $proj = "FlopC++" ]; then
        new_url+="FlopCpp"
    elif [ $proj = "CoinBazaar" ]; then
        if [ $dir = "examples" ]; then
            new_url+="ApplicationTemplates"
        fi
    else
        new_url+=$proj
    fi
    echo $new_url

}

###################################################################################
# Prompt user for what actionas to perform
###################################################################################

function prompt_for_action {

    # Prompt user for what actions to perform
    echo "Please choose an action by typing 1-4."
    echo " 1. Fetch source code of a project and its dependencies."
    echo " 2. Build a project and its dependencies."
    echo " 3. Install a project and its dependencies."
    echo " 4. Help"
    echo -n "=> "
    read choice
    case $choice in
        1)
            fetch=true
            ;;
        2)
            build=true
            echo "Please specify a build directory (can be relative or absolute)."
            echo -n "=> "
            read user_build_dir
            case $user_build_dir in
                [\\/$]* | ?:[\\/]* | NONE | '' )
                    build_dir=$user_build_dir
                    ;;
                *)
                    build_dir=$PWD/$user_build_dir
                    ;;
            esac
            ;;
        3) 
            install=true
            echo "Please specify an install directory (can be relative or absolute)."
            echo -n "=> "
            read prefix
            ;;
        4)
            help
            die "" 0
            ;;
    esac

}

###################################################################################
# Prompt user for main project
###################################################################################

function prompt_for_main {

    # Prompt user to pick a main project or return error
    echo
    echo "Please choose a main project to fetch/build by typing 1-18"
    echo "or simply type the repository name of another project not" 
    echo "listed here."
    echo " 1. Osi"
    echo " 2. Clp"
    echo " 3. Cbc"
    echo " 4. DyLP"
    echo " 5. FlopC++"
    echo " 6. Vol"
    echo " 7. SYMPHONY"
    echo " 8. Smi"
    echo " 9. CoinMP"
    echo " 10. Bcp"
    echo " 11. Ipopt"
    echo " 12. Alps"
    echo " 13. BiCePS"
    echo " 14. Blis"
    echo " 15. Dip"
    echo " 16. Bonmin"
    echo " 17. Couenne"
    echo " 18. Optimization Services"
    echo " 19. MibS"
    echo " 20. DisCO"
    echo " 21. COIN-OR-OptimizationSuite (everything)"
    echo " 22. Let me enter another project"
    echo -n "=> "
    read choice
    echo
    case $choice in
        1)  main_proj=Osi;;
        2)  main_proj=Clp;;
        3)  main_proj=Cbc;;
        4)  main_proj=DyLP;;
        5)  main_proj=FlopCpp;;
        6)  main_proj=Vol;;
        7)  main_proj=SYMPHONY;;
        8)  main_proj=Smi;;
        9)  main_proj=CoinMP;;
        10)  main_proj=Bcp;;
        11)  main_proj=Ipopt;;
        12)  main_proj=CHiPPS-ALPS;;
        13)  main_proj=CHiPPS-BiCePS;;
        14)  main_proj=CHiPPS-BLIS;;
        15)  main_proj=Dip;;
        16)  main_proj=Bonmin;;
        17)  main_proj=Couenne;;
        18)  main_proj=OS;;
        19)  main_proj=MibS;;
        20)  main_proj=DisCO;;
        21)  main_proj=COIN-OR-OptimizationSuite;;
        22)
            echo "Enter the name or URL of the project"
            echo -n "=> "
            read choice2
            main_proj=$choice2
            ;;
        *)  main_proj=$choice;;
    esac

}

###################################################################################
# Ask user whether to fetch
###################################################################################

function prompt_for_fetch {

    echo "Fetch now? y/n"
    got_choice=false
    while [ $got_choice = "false" ]; do
        echo -n "=> "
        read choice
        case $choice in
            y|n) got_choice=true;;
            *) ;;
        esac
    done
    case $choice in
        y)
            fetch="true"
            ;;
        n)
            ;;
    esac

}

###################################################################################
# Ask user what verion to install
###################################################################################

function prompt_for_version {

    echo
    echo "You haven't specified a project version"
    echo "It appears that the last 10 releases of $main_proj are"
    git ls-remote --tags $main_proj_url | fgrep releases | fgrep -v -e "^{}" | \
        cut -d '/' -f 4 | sort -nr -t. -k1,1 -k2,2 -k3,3 | head -10
    echo "Do you want to work with the latest release? (y/n)"
    got_choice=false
    while [ $got_choice = "false" ]; do
        echo -n "=> "
        read choice
        case $choice in
            y|n) got_choice=true;;
            *) ;;
        esac
    done
    case $choice in
        y) main_proj_version=releases/$(git ls-remote --tags $main_proj_url | \
                                            fgrep releases | \
                                            fgrep -v -e "^{}" | \
                                            cut -d '/' -f 4 | \
                                            sort -nr -t. -k1,1 -k2,2 -k3,3 | \
                                            head -1)
           ;;
        n) echo "Please enter another version name in the form of"
           echo 'master', 'releases/x.y.z', or 'stable/x.y'
           echo -n "=> "
           read choice
           main_proj_version=$choice
           ;;
    esac
    echo

}

###################################################################################
# Ask user what to do when there are new configuration options for rebuild
###################################################################################

function prompt_for_rebuild {
    
    echo "Please choose one of the following options."
    echo " The indicated action will be performed for you AUTOMATICALLY"
    echo "1. Run the build again with the previously specified options."
    echo "   This can also be accomplished invoking the build"
    echo "   command without any arguments."
    echo "2. Configure in a new build directory (whose name you will be"
    echo "   prmpted to specify) with new options."
    echo "3. Re-configure in the same build directory with the new"
    echo "   options. This option is not recommended unless you know"
    echo "   what you're doing!."
    echo "4. Quit"
    echo
    got_choice=false
    while [ $got_choice = "false" ]; do
        echo "Please type 1, 2, 3, or 4"
        echo -n "=> "
        read choice
        case $choice in
            1|2|3|4) got_choice=true;;
            *) ;;
        esac
    done
    case $choice in
        1)  ;;
        2)
            echo "Please enter a new build directory:"
            echo -n "=> "
            read dir
            if [ x"$dir" != x ]; then
                case $dir in
                    [\\/$]* | ?:[\\/]* | NONE | '' )
                        build_dir=$dir
                        ;;
                    *)
                        build_dir=$PWD/$dir
                        ;;
                esac
            fi
            ;;
        3)
            rm $build_dir/.config/$main_proj-$main_proj_version
            reconfigure=true
            ;;
        4)
            die "Exiting." 0
    esac

}

###################################################################################
# Make list of dependencies by parsing either Dependencies or config.yml
###################################################################################

function parse_dependencies_file {
    dep_file=
    if [ "$main_proj" = "" ]; then
        if [ -e .coin-or/config.yml ] && [ $read_yaml = true ]; then
            dep_file=.coin-or/config.yml
        elif [ -e Dependencies ];  then
            dep_file=Dependencies
        elif [ -e .coin-or/Dependencies ]; then
            dep_file=.coin-or/Dependencies
        fi
    else
        if [ -e $main_proj_dir/.coin-or/config.yml ] &&
               [ $read_yaml = true ]; then
            dep_file=$main_proj_dir/.coin-or/config.yml
        elif [ -e $main_proj_dir/Dependencies ]; then
            dep_file=$main_proj_dir/Dependencies
        elif [ -e $main_proj_dir/.coin-or/Dependencies ]; then
            dep_file=$main_proj_dir/.coin-or/Dependencies
        elif [ -e $main_proj_dir/$main_proj_dir/Dependencies ] && [ $read_yaml = false ]; then
            dep_file=$main_proj_dir/$main_proj_dir/Dependencies
        fi
    fi

    if [ "$dep_file" != "" ]; then
        if [[ $dep_file == *Dependencies ]]; then
            #This is for parsing the old style Dependencies file
            deps=$(cat $dep_file | tr '\t' ' ' | tr -s ' ')
            for entry in $deps
            do
                if expr "$entry" : '^#' > /dev/null 2>&1; then continue ; fi
                dir=$(echo $entry | tr '\t' ' ' | tr -s ' '| cut -d ' ' -f 1)
                url=$(echo $entry | tr '\t' ' ' | tr -s ' '| cut -d ' ' -f 2)
                proj=$(echo $url | cut -d '/' -f 5)
                # Determine the desired version
                if [[ $url == *github* ]]; then
                    #The URL is for a git project
                    version=$(echo $entry | tr '\t' ' ' | tr -s ' '| cut -d ' ' -f 3)
                    if [ $version != "master" ]; then
                        version_num=$(echo $version | cut -d '/' -f 2)
                    else
                        version_num=master
                    fi
                else
                    #The URL is for an old SVN project
                    version=$(get_version_svn $url)
                    if [ $(echo $version | cut -d '/' -f 1) = "branches" ]; then
                        version=$(echo $version | cut -d '/' -f 2)
                    fi
                    if [ $version = "trunk" ]; then
                        version=master
                        version_num=master
                    else
                        version_num=$(echo $version | cut -d '/' -f 2)
                    fi
                    url=$(svn2git)
                fi
                urls+=( $url )
                pdirs+=( $dir )
                projs+=( $proj )
                versions+=( $version )
                version_nums+=( $version_num )
                requireds+=( Required )
            done
        else
            #This is for parsing the new YAML file
            create_variables $dep_file
            for ((count=0; count<${#Dependencies__URL[@]}; ++count))
            do
                if [[ ${Dependencies__URL[count]} != *github* ]]; then
                    continue
                fi
                
                if [ $ssh_checkout = true ]; then
                    urls+=( $(echo ${Dependencies__URL[count]} |
                                  sed 's|https://github.com/|git@github.com:|') )
                else
                    urls+=( ${Dependencies__URL[count]} )
                fi
                pdirs+=( $(echo ${Dependencies__URL[count]} | cut -d '/' -f 5 |
                               sed 's|-|/|') ) 
                projs+=( $(echo ${pdirs[count]} | cut -d '/' -f 2) )
                version_nums+=( ${Dependencies__Version[count]} )
                case $(echo ${version_nums[count]} | tr -cd '.' | wc -c | tr -d ' ') in
                    1)
			if [[ ${version_nums[count]} != stable* ]]; then
                            versions+=( stable/${version_nums[count]} )
			else
			    versions+=( ${version_nums[count]} )
			fi
                        ;;
                    2)
			if [[ ${version_nums[count]} != releases* ]]; then
                            versions+=( releases/${version_nums[count]} )
			else
			    versions+=( ${version_nums[count]} )
			fi
                        ;;
                    *)
                        versions+=( ${version_nums[count]} )
                        ;;
                esac
                requireds+=( ${Dependencies__Required[count]} )
            done
        fi
    else
        echo "No dependencies file found, only main project will be built"
        echo
        deps=
    fi

}

###################################################################################
# Fetch or update one project
###################################################################################

function fetch_proj {

    current_rev=
    if [ -d $dir ]; then
        # If the project is already checked out, then check whether the checked out
        # version is the correct one. Switch if necessary. Otherwise, just update
        pushd_ $dir
        current_version=$(get_version_git)
        current_rev=$(git rev-parse HEAD)
        if [ $get_latest_release = "true" ] && [[ $version != releases/* ]]; then
            if [[ $version != stable/* ]]; then
                echo "Warning: Dependency is not a stable version, will not be converted to release"
            else 
                tmp=$(git tag --list "${version/stable/releases}*" \
                          | sort -V | tail -1)
                if [ x$tmp != x ]; then
                    version=$tmp
                fi
            fi
        fi
        if [ $keep_current = "true" ]; then
            version=$current_version
        fi
        if ([[ $version != *$current_version ]] &&
                [ $(git rev-parse $version) != $current_rev ]) ||
               ([ "$sha" != "" ] && [[ $current_rev != $sha* ]]) ||
               [ "$checkout_time" != "" ]; then
            git fetch --tags
            if [ "$sha" != "" ]; then
                print_action "Switching $dir to SHA $sha"
                stashed=false
                if [ $auto_stash = true ]; then
                    if [[ $(git stash save) == "No" ]]; then
                        stashed=false
                    fi
                fi
                git checkout $sha
                if [ $auto_stash = true ] && [ $stashed = true ]; then
                    # We should check whether this succeeds somehow...
                    git stash pop
                fi
            elif [ x"$checkout_time" != x ]; then
                print_action "Checking out $dir version $version as of $checkout_time"
                git checkout $(git rev-list -n 1 --first-parent --before="$checkout_time" \
                                   remotes/origin/$version)
            else
                if [ $rebase = "true" ]; then
                    print_action "Switching $dir to $version and rebasing"
                else
                    print_action "Switching $dir to $version and updating"
                fi
                git checkout $version
            fi
            if [ $(git branch | grep \* | cut -d ' ' -f 2) != "(HEAD" ] &&
                   [ $(git branch | grep \* | cut -d ' ' -f 2) != "(no" ] &&
                   [ $(git branch | grep \* | cut -d ' ' -f 2) != "(detached" ]; then
                # We should somehow check whether this causes conflicts
                if [ $rebase = "true" ]; then
                    git pull --rebase --autostash
                else
                    git pull
                fi
            fi
        else
            if [ $(git branch | grep \* | cut -d ' ' -f 2) != "(HEAD" ] &&
                   [ $(git branch | grep \* | cut -d ' ' -f 2) != "(no" ] &&
                   [ $(git branch | grep \* | cut -d ' ' -f 2) != "(detached" ]; then
                # We should somehow check whether this causes conflicts
                if [ $rebase = "true" ]; then
                    print_action "Rebasing $dir $version"
                    git pull --rebase --autostash
                else
                    print_action "Updating $dir $version"
                    git pull
                fi
            else
                print_action "$dir version is a release (skipping update)"
            fi
        fi
        new_rev=$(git rev-parse HEAD)
    else
        if [ $get_latest_release = "true" ] && [[ $version != releases/* ]]; then 
            latest_release=$(git ls-remote --tags $url)
            if echo "$latest_release" | fgrep releases &> /dev/null ; then
                tmp=$(echo "$latest_release" | fgrep releases | \
                          fgrep -v -e "^{}" | \
	  	          cut -d '/' -f 4 | awk "/^${version_num/\//\\\/}/{print;}" | \
                          sort -nr -t. -k1,1 -k2,2 -k3,3 | head -1)
                if [ "$tmp" != "" ]; then
                    version=releases/$tmp
                else
                    echo "No release found, using version $version"
                fi
            fi
        fi
        # If project is not checked out yet, just check out the correct version
        if [ $sparse = "true" ]; then
            print_action "Fetching $dir $version"
            mkdir $dir
            pushd_ $dir
            git init
            git remote add origin $url
            git config core.sparsecheckout true
            echo $proj/ >> .git/info/sparse-checkout
            git fetch --tags
            git checkout $version
        else
            if [ "$sha" = "" ]; then
                print_action "Fetching $dir $version"
                git clone --branch=$version $url $dir
            else
                print_action "Fetching $dir SHA $sha"
                git clone $url $dir
                pushd_ $dir
                git checkout $sha
                popd_
            fi
            pushd_ $dir
        fi     
        new_rev=$(git rev-parse HEAD)
    fi
    popd_

    # If this is a third party project, fetch the source if desired
    if [ $get_third_party = "true" ] &&
           [ "$current_rev" != "$new_rev" ] &&
           [ $(echo $dir | cut -d '/' -f 1) = ThirdParty ]; then
        tp_proj=$(echo $dir | cut -d '/' -f 2)
        if [ -e $dir/get.$tp_proj ]; then
            pushd_ $dir
            ./get.$tp_proj
            touch .build
            popd_
        else
            echo "Not downloading source for $tp_proj..."
        fi
    fi  

}
        
###################################################################################
# Wrapper for invoking make with different verbosities
###################################################################################

function invoke_make {

    v=$1
    shift
    if [ $v = 1 ]; then
        set +e
        $sudo $MAKE -j $jobs $@ > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            $sudo $MAKE -j $jobs $@ > /dev/null
            msg ""
            die "Error: ${RED}Build failed, see error output above${NOFORMAT}" 1
        fi
        set -e
    elif [ $v = 2 ]; then
        set +e
        $sudo $MAKE -j $jobs $@ 2> /dev/null
        if [ $? -ne 0 ]; then
            $sudo $MAKE -j $jobs $@ > /dev/null
            msg ""
            die "Error: ${RED}Build failed, see error output above${NOFORMAT}" 1
        fi
        set -e
    else
        $sudo $MAKE V=$(($v-3)) -j $jobs $@
    fi

}

###################################################################################
# Do the build of one project
###################################################################################

function build_proj {

    mkdir -p $build_dir/$dir/$version_num
    echo -n $dir/$version_num" " >> $build_dir/coin_subdirs.txt
    pushd_ $build_dir/$dir/$version_num
    
    if [ ! -e config.status ] || [ $reconfigure = "true" ]; then
        if [ $reconfigure = "true" ]; then
            print_action "Reconfiguring $dir $version_num"
        else
            print_action "Configuring $dir $version_num"
        fi
        if [ -e $root_dir/$dir/$dir/configure ]; then
            config_script="$root_dir/$dir/$dir/configure"
        else
            config_script="$root_dir/$dir/configure"
        fi
        if [ $verbosity -ge 4 ] || ( [ $verbosity -ge 2 ] &&
                                         [ "$main_proj" != "" ] &&
                                         [ $main_proj_dir = $dir ]); then
            "$config_script" --disable-dependency-tracking --prefix=$prefix \
                             "${!configure_options[@]}"
        else
            set +e
            "$config_script" --disable-dependency-tracking --disable-option-checking \
                             --prefix=$prefix "${!configure_options[@]}" > /dev/null
            if [ $? -ne 0 ]; then
                msg ""
                msg "Configuration failed, re-running with output enabled"
                msg ""
                "$config_script" --disable-dependency-tracking --prefix=$prefix \
                                 "${!configure_options[@]}"
                msg ""
                msg "Here is the contents of config.log"
                msg ""
                cat config.log
                if [ "$(command -v pkg-config)" = "" ] &&
                       [ "$(command -v pkgconf)" = "" ]; then
                    msg "${RED}No pkg-config or pkgconf were found on your system"
                    msg "If packages were not found during configuration," 
                    msg "this could be the reason."
                    msg "Installation is highly recommended."
                    msg "See https://coin-or.github.io for details${NOFORMAT}"
                fi
                die "" 1
            fi
            set -e
        fi
    fi
    if [ $rebuild = "true" ]; then
        print_action "Cleaning $dir"
        if [ $verbosity = 4 ]; then
            $MAKE clean
        else
            set +e
            $MAKE clean > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                $sudo $MAKE clean > /dev/null
                msg
                msg "Error: ${RED}Build failed, see error output above"
                msg
                die "${NOFORMAT}" 1
            fi
            set -e
        fi
    fi
    print_action "Building $dir $version_num"
    if [ $verbosity -ge 2 ]; then
        if [ "$main_proj" != "" ] && [ $main_proj_dir = $dir ]; then
            invoke_make $verbosity ""
        else
            invoke_make $(($verbosity-1)) ""
        fi
    else
        invoke_make 1 ""
    fi
    if [ $run_tests = "all" ] ||
           ([ $run_tests = "main" ] && [ "$main_proj" != "" ] && [ $main_proj_dir = $dir ]); then
        print_action "Running $dir unit test"
        # Fix for systems where the unit test doesn't seem to run with specifying LD_LIBRARY_PATH
        export LD_LIBRARY_PATH="$prefix/lib:${LD_LIBRARY_PATH:-}"
        if [ $verbosity -ge 2 ]; then
            if [ "$main_proj" != "" ] && [ $main_proj_dir = $dir ]; then
                invoke_make $((verbosity)) test
            else
                invoke_make 1 test
            fi
        else
            invoke_make 1 test
        fi
    fi
    popd_

}

###################################################################################
# Install a project
###################################################################################

function install_proj {

    if [ -d $build_dir/$dir/$version_num ]; then
        print_action "Installing $dir $version_num"
        pushd_ $build_dir/$dir/$version_num
        sudo=""
        if [ ! -w $prefix ]; then
            if [ ! $(id -u) = 0 ]; then
                echo "Prefix is not writable."
                echo "Install step will be run with sudo"
                sudo=sudo
            fi
        fi
        if [ $verbosity -ge 4 ]; then
            invoke_make 4 install
        else
            invoke_make 1 install
        fi
        popd_
    fi
}

###################################################################################
# Uninstall a project
###################################################################################

function uninstall_proj {

    if [ -d $build_dir/$dir/$version_num ]; then
        print_action "Uninstalling $dir"
        pushd_ $build_dir/$dir/$version_num
        sudo=""
        if [ ! -w $prefix ]; then
            if [ ! $(id -u) = 0 ]; then
                echo "Prefix is not writable."
                echo "Uninstall step needs to be run with sudo"
                sudo=sudo
            fi
        fi
        if [ $verbosity -ge 4 ]; then
            invoke_make 4 uninstall
        else
            invoke_make 1 uninstall
        fi
        popd_
    fi

}

###################################################################################
# Download binaries
###################################################################################

function download_binaries {
    
    pushd_ $prefix
    if [ x"$download_projs" = x ]; then
        download_projs=${main_proj}@${version_num}
    fi
    for dl_proj in $download_projs
    do
        found_proj=false
        case $dl_proj in
            Cbc*)
                additional_skip_projects="Cbc Cgl Clp Osi CoinUtils Data/Sample Data/miplib3"
                found_proj=true
                # Why do we need to do this? It should be enough to set PKG_CONFIG_PATH
                if [[ $platform == *msvc* ]]; then
                    configure_options=["--with-cbc-lib='$prefix/lib/CbcSolver.lib $prefix/lib/Cbc.lib $prefix/lib/Cgl.lib $prefix/lib/OsiClp.lib $prefix/lib/Clp.lib $prefix/lib/OsiCommonTest.lib $prefix/lib/Osi.lib $prefix/lib/CoinUtils.lib $prefix/lib/coinglpk.lib $prefix/lib/coinasl.lib'"]
                    if [ $version_num = "master" ]; then
                        configure_options=["--with-cbc-incdir='$prefix/include/coin-or"]
                    else
                        configure_options=["--with-cbc-incdir='$prefix/include/coin"]
                    fi
                fi
                ;;
            *)
                echo "Downloading of binaries for $main_proj not supported yet"
                ;;
        esac
        if [ $found_proj = true ]; then
            if [[ $dl_proj == *@* ]]; then
                dl_proj_version=${dl_proj##*@}
                dl_proj=${dl_proj%@*}
                dl_proj_version_num=$(echo $dl_proj_version | cut -d '/' -f 2)
            else
                echo "Warning: No project version specified for $dl_proj binary, getting master"
                dl_proj_version=master
            fi
            if [[ $platform == *msvc* ]]; then
                download_file=$dl_proj-$dl_proj_version_num-$platform.zip
            else
                download_file=$dl_proj-$dl_proj_version_num-$platform.tgz
            fi
            wget https://bintray.com/coin-or/download/download_file?file_path=$download_file \
                 -O $download_file
            if [[ $platform == *msvc* ]]; then
                unzip $download_file
            else
                tar -xzf $download_file
            fi
            rm $download_file
            coin_skip_projects="${coin_skip_projects:-} $additional_skip_projects"
        fi
    done
    popd_

}

###################################################################################
# Get cached build options
###################################################################################

function get_cached_options {

    local lclFile="$1"
    echo "Reading cached options from $lclFile"
    # read options from file, one option per line, and store into array copts
    readarray -t copts < "$lclFile"
    # move options from copts[0], copts[1], ... into
    # configure_options, where they are stored as the keys
    # skip options that are empty (happens when reading empty .config file)
    for c in ${!copts[*]} ; do
        [ -z "${copts[$c]}" ] && continue
        if [ "${copts[$c]}" = "--no-third-party" ]; then
            get_third_party=false
            continue
        fi
        configure_options["${copts[$c]}"]=""
    done
    # print configuration options, one per line
    # (TODO might need verbosity level check)
    printf "%s\n" "${!configure_options[@]}"

}

###################################################################################
# Some utility routines
###################################################################################

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # script cleanup here
}

setup_colors() {
    if [[ $use_color == true ]] && [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] &&
           [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m'
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        ORANGE='\033[0;33m'
        BLUE='\033[0;34m'
        PURPLE='\033[0;35m'
        CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        NOFORMAT=''
        RED=''
        GREEN=''
        ORANGE=''
        BLUE=''
        PURPLE=''
        CYAN=''
        YELLOW=''
    fi
}

msg() {
    echo >&2 -e "${1-}"
}

die() {
    local msg=$1
    local code=${2-1} # default exit status 1
    msg "$msg"
    exit "$code"
}

###########################################################################
# Main script starts here
###########################################################################

echo "Welcome to the COIN-OR fetch and build utility, version 2"
echo 
echo "To use the legacy version of coinbrew, '$ wget https://raw.githubusercontent.com/coin-or/coinbrew/v1.0/coinbrew'"
echo "For help, run script with --help or see https://coin-or.github.io/coinbrew"
echo "Please report issues at https://github.com/coin-or/coinbrew"
echo "Detailed build documentation at https://coin-or.github.io"
echo 

###################################################################################
# Check bash version, existence of pkg-config,  and set variables
###################################################################################

if [ $(echo ${BASH_VERSION} | cut -d "." -f 1) -le "3" ]; then
    msg "Error: ${RED}This script requires bash version 4 or greater."
    msg "You are probably on macOS, which comes with version 3."
    msg "Please install a recent bash using homebrew (https://brew.sh)."
    die "${NOFORMAT}Exiting." 100
fi

if [ "$(command -v pkg-config)" = "" ] && [ "$(command -v pkgconf)" = "" ]; then
    msg "${RED}No pkg-config or pkgconf found on system"
    msg "If packages are not found during configuration," 
    msg "this could be the reason. Installation is highly recommended."
    msg "See https://coin-or.github.io for details"
    msg "${NOFORMAT}"
fi

# Exit when command fails
set -Ee
#Attempt to use undefined variable outputs error message, and forces an exit
set -u
#Causes a pipeline to return the exit status of the last command in the pipe
#that returned a non-zero return value.
set -o pipefail

#Take care of issues caused by other languages
export LC_NUMERIC="en_US.UTF-8"
export LANG="en_US.UTF-8"

#Trap some signals
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# Set defaults
root_dir=$PWD
declare -i num_actions
num_actions=0
sparse=false
prefix=
coin_skip_projects=
fetch=false
build=false
install=false
uninstall=false
download=false
run_tests=all
declare -A configure_options
configure_options=()
jobs=1
build_dir=
rebuild=false
reconfigure=false
get_third_party=true
verbosity=1
main_proj=
main_proj_version=
main_proj_sha=
main_proj_dir=
MAKE=make
no_prompt=false
skip_update=false
ssh_checkout=false
configure_help=false
sudo=""
checkout_time=
disable_uninstalled=true
enable_debug=false
skip_dependencies=false
get_latest_release=false
auto_stash=false
download_projs=
keep_current=false
rebase=true
use_color=true
offline=false
read_yaml=true
write_yaml=false
get_optional=false
get_recommended=true
if [ ssh_checkout = "true" ]; then
    url_prefix="git@github.com:coin-or"
else
    url_prefix="https://github.com/coin-or"
fi

###################################################################################
# Parse the command-line arguments
###################################################################################

setup_colors
parse_args "$@"

###################################################################################
# Set the default build directory
###################################################################################

if [ $build = "true" ] || [ $install = "true" ] || [ $uninstall = "true" ]; then

    if [ "$build_dir" = "" ] ; then
        if [ $enable_debug = "false" ]; then
            build_dir=$root_dir/build
        else
            build_dir=$root_dir/build-debug
        fi
    fi
    
    #Try to create the build directory if it doesn't exist
    if [ ! -d $build_dir ]; then
        set +e
        mkdir -p $build_dir 2> /dev/null
        set -e
    fi
    
    #Check whether build directory creation was successful
    if [ ! -d $build_dir ]; then
        msg "Error: ${RED}Build directory cannot be created."
        msg "Please create it and make it writable."
        msg "Then re-run script"
        die "${NOFORMAT}Exiting." 4
    fi
    echo "Package will be built in $build_dir"
    echo
fi

###################################################################################
# Check to see if user specified an action and prompt if not
###################################################################################

if [ $num_actions = 0 ]; then
    if [ $no_prompt = false ]; then
        prompt_for_action
    else
        if [ $configure_help = false ]; then
            help
            die "" 0
        fi
    fi
fi

###################################################################################
# Sanity checks
###################################################################################

if [ x"$prefix" != x ] && [ $build = "false" ] && [ $download = false ] &&
       [ $install = false ]; then
    die "Error: ${RED}Prefix should only be specified with build, download, or install commands.${NOFORMAT}" 3
fi

if [ $download = "true" ] && [ $fetch = "false" ] && [ $build = "false" ] &&
       [ $install = "false" ] && [ $uninstall = "false" ]; then
    skip_dependencies=true
fi

###################################################################################
# Check to see if user specified a project and prompt if not
###################################################################################

if [ "$main_proj" = "" ]; then
    if [ $no_prompt = false ]; then
        prompt_for_main
    else
        if [ $configure_help = "true" ]; then
            echo "For help with problem configuration, please specify a project"
            echo "For example 'coinbrew Xyz --configure-help'"
        else
            echo "In non-interactive mode, main project must be specified."
        fi
        die "Exiting." 20
    fi
fi

###################################################################################
# Check if the user specified a fork and if so, extract project name from it
# Otherwise, set URL provisionally (might change if project is already checked out)
###################################################################################

if [[ $main_proj == https* ]] || [[ $main_proj == git* ]]; then
    #We assume this is a fork of a git project
    main_proj_url=$main_proj
    if [ $(echo $main_proj | cut -d ':' -f 1) = https ]; then
        main_proj=$(echo $main_proj_url | cut -d '/' -f 5 | cut -d '.' -f 1)
    else
        main_proj=$(echo $main_proj | cut -d '/' -f 2 | cut -d '.' -f 1)
    fi
else
    #Need to map these from directory name to repo name
    case $main_proj in
        Alps)
            main_proj=CHiPPS-ALPS
            ;;
        Bcps)
            main_proj=CHiPPS-BiCePS
            ;;
        Blis)
            main_proj=CHiPPS-BLIS
            ;;
    esac
    main_proj_url=$url_prefix/$main_proj
fi

### Main Project should now be set ###

###################################################################################
# Figure out main project directory
###################################################################################

if [ "$(echo $main_proj | cut -d '-' -f 1)" = "CHiPPS" ]; then
    case $(echo $main_proj | cut -d '-' -f 2) in
        ALPS)
            if [ -d CHiPPS-ALPS ] && [ ! -d Alps ]; then
                ln -s CHiPPS-ALPS Alps
            fi
            main_proj_dir=Alps
            ;;
        BiCePS)
            if [ -d CHiPPS-BiCePS ] && [ ! -d Bcps ]; then
                ln -s CHiPPS-BiCePS Bcps
            fi
            main_proj_dir=Bcps
            ;;
        BLIS)
            if [ -d CHiPPS-BLIS ] && [ ! -d Blis ]; then
                ln -s CHiPPS-BLIS Blis
            fi
            main_proj_dir=Blis
            ;;
    esac
else
    main_proj_dir=$main_proj
fi

###################################################################################
# Figure out what version the user really wants
###################################################################################

if [ $offline = "false" ]; then
    latest_release=$(git ls-remote --tags $main_proj_url)
fi
if echo "$latest_release" | fgrep releases &> /dev/null ; then
    latest_release=$(echo "$latest_release" | fgrep releases | \
                         fgrep -v -e "^{}" | \
	  	         cut -d '/' -f 4 | sort -nr -t. -k1,1 -k2,2 -k3,3 | \
                         head -1)
fi
if [ $get_latest_release = "true" ] ; then
    if [ -n "$latest_release" ] ; then
        if [[ "$main_proj_version" != releases/* ]]; then
            echo 
            if [ "$main_proj_version" != "" ]; then
                echo "Fetching latest release $latest_release rather than specified version $main_proj_version."
            else
                echo "Fetching latest release $latest_release"
            fi
            echo
            main_proj_version="releases/$latest_release"
        fi
    else
	echo
	die "Error: ${RED}It appears that $main_proj has no releases. You'll need to specify a branch as ${main_proj}:branch.${NOFORMAT}" 31
    fi
fi

if [ "$main_proj" != "" ] && [ "$main_proj_version" = "" ] && [ $fetch = true ] &&
       [ $no_prompt = false ] && [ $skip_update = "false" ]; then
    prompt_for_version
fi

if [ "$main_proj_version" != "" ] && [ $build = "true" ] && [ $fetch != "true" ] &&
       [ -d $main_proj_dir ]; then
    echo
    echo "It appears that a main project version has been specified, but"
    echo "fetching was not requested. Build will proceed with current version."
    echo
fi

if [[ $main_proj_version == releases/* ]]; then
    get_latest_release=true
fi

###################################################################################
# Check whether project is already checked out and set URL appropriately
###################################################################################

if [ -d $main_proj_dir ]; then
    pushd_ $main_proj_dir
    # Possibly switch url and version for existing projects
    current_proj_url=$(git remote -v |  fgrep origin | fgrep fetch | tr '\t' ' ' |\
                           tr -s ' '| cut -d ' ' -f 2 | sed s"|\.git||")
    if [ $(echo $main_proj_url | sed 's|https://github.com/||' | sed 's|git@github.com:||') != \
         $(echo $current_proj_url | sed 's|https://github.com/||' | sed 's|git@github.com:||') ]
    then
        echo
        echo "Warning: specified a fork when project is already cloned from a different repo."
        echo "Proceeding with existing repo."
        echo
        main_proj_url=$current_proj_url
    fi
    if [ $skip_update = "true" ] || [ $fetch = "false" ] ||
           [ "$main_proj_version" = "" ]; then
        main_proj_version=$(get_version_git)
        if [[ $main_proj_version == releases/* ]]; then
           get_latest_release=true
        fi
        if [ $build = "true" ]; then
            echo "################################################"
            echo "### Building version $main_proj_version"
            echo "### with existing versions of dependencies."
            echo "### Ctrl-c and run 'fetch' to switch versions" 
            echo "### or to ensure correct dependencies"
            echo "################################################"
            echo
        fi
    fi
    popd_
else
    # If we get here without a version set, then default to latest release
    if [ "$main_proj_version" = "" ]; then
        if [ $no_prompt = true ]; then
            echo "NOTE: You didn't provide a version."
            echo "      Defaulting to the latest release $latest_release."
            echo
            main_proj_version=releases/$latest_release
            get_latest_release=true
        else
            prompt_for_version
        fi
    fi
    if [ $fetch = "false" ]; then
       # Project is not checked out and fetching is not requested
       echo "It appears that project has not been fetched yet."
       if [ $configure_help = "false" ]; then
           echo "Fetching will be done automatically..."
           fetch=true
       else
           die "Error: ${RED}Please fetch before asking for help on configuration.${NOFORMAT}" 30
       fi
    fi
fi
    
###################################################################################
# This changes the default separator used in for loops to carriage return.
# We need this later.
###################################################################################

TMP_IFS=$IFS
IFS=$'\n'

###################################################################################
# Clean up the version number. Trickery! For something like releases/1.5.4,
# this will return just 1.5.4.  But if there's no '/', you get the whole
# thing back, hence arbitrary branch names like trunk or autotools-update
# come through just fine.
###################################################################################

version_num=$(echo $main_proj_version | cut -d '/' -f 2)

###################################################################################
# Cache configuration options or get previously cached options
# Notify user if options were specified but cached options exist
###################################################################################

if [ $build = "true" ]; then
    if [ -e $build_dir/.config/$main_proj-$version_num ] && [ $reconfigure = "false" ]; then
        echo "###"
        echo "### Cached configuration options from previous build found."
        echo "###"
        if [ x"${#configure_options[*]}" != x0 ]; then
            echo
            echo "You are trying to run the build again and have specified"
            echo "configuration options on the command line."
            echo
            if [ $no_prompt = false ]; then
                prompt_for_rebuild
            else
                echo "Options specifed on command line being ignored."
                echo "  - If you wish to use new options in the same build"
                echo "    directory, re-run with --reconfigure"
                echo "  - If you wish to build in a new directory,"
                echo "    re-run with --build-dir"
                configure_options=()
            fi
        fi
    fi
    if [ ! -e $build_dir/.config/$main_proj-$version_num ] || [ $reconfigure = "true" ]; then
        echo "Caching configuration options..."
        mkdir -p $build_dir/.config
        printf "%s\n" "${!configure_options[@]}" > \
               $build_dir/.config/$main_proj-$version_num
        printf "%s\n" "${!configure_options[@]}"
        if [ $get_third_party = "false" ]; then
            echo "--no-third-party" >> \
	         $build_dir/.config/$main_proj-$version_num
        fi
    else
        get_cached_options $build_dir/.config/$main_proj-$version_num
        # Only needed for projects with old build tools
        for i in $(cat $build_dir/.config/$main_proj-$version_num)
        do
            if [[ "$i" == --with-coin-instdir* ]]; then
                prefix=$(echo $i | cut -d '=' -f 2)
            fi
        done
    fi
fi

###################################################################################
# Set the install directory. 
###################################################################################

if [ $build = "true" ] || [ $download = "true" ]; then
    echo
    echo "Installation is done automatically following build and test of each project."
    echo
    install=true
fi
if [ $install = "true" ]; then
    if [ "$prefix" = "" ]; then
        prefix=$root_dir/dist
        mkdir -p $root_dir/dist
    elif [ ! -d $prefix ]; then
        set +e
        mkdir -p $prefix 2> /dev/null
        set -e
    fi
    if [ -w $prefix ]; then
        echo "Installation directory is writable."
        echo
    else
        echo "Installation directory is not writable."
        echo "Sudo authentication will be required for installation."
        echo "NOTE: Only commands related to installation"
        echo "      will be run with sudo. Builds are done as normal user."
        sudo mkdir -p $prefix
    fi
    configure_options["--with-coin-instdir=$prefix"]=""
    echo "Package will be installed to $prefix "
    echo
fi

###################################################################################
# Find out if we're supposed to skip any projects
###################################################################################

find_skip_projects

###################################################################################
# If we're going to download and install any binaries, do that first
###################################################################################

if [ $download = "true" ]; then
    download_binaries
fi

###################################################################################
# Now fetch main project
###################################################################################

if [ "$main_proj" != "" ]; then
    url=$main_proj_url
    dir=$main_proj_dir
    proj=$main_proj
    version=$main_proj_version
    required=Required
    
    sha=$main_proj_sha
    if should_fetch; then
        fetch_proj 
    elif [ $fetch = "true" ]; then
        print_action "Skipping update of $dir"
    fi
    if [ $configure_help = true ]; then
        echo "Here is the help output for the main configure script."
        echo
        if [ -e $dir/$dir/configure ]; then
            $dir/$dir/configure --help
        elif [ -e $dir/configure ]; then
            $dir/configure --help
        else
            echo "Can't find configure file for main project!"
        fi
        die "Exiting." 0
    fi
fi

###################################################################################
# Build list of dependencies
###################################################################################

declare -a pdirs
declare -a urls
declare -a projs
declare -a versions
declare -a version_nums
declare -a required
pdirs=()
urls=()
projs=()
versions=()
version_nums=()
requireds=()

if [ $skip_dependencies = "false" ]; then
    parse_dependencies_file
fi

###################################################################################
# Add main project to list (if one is specified)
###################################################################################

if [ "$main_proj" != "" ]; then
    urls+=( $main_proj_url )
    pdirs+=( $main_proj_dir )
    projs+=( $main_proj )
    versions+=( $main_proj_version )
    if [ $main_proj_version = master ]; then
        version_nums+=( master )
    else
        version_nums+=( $(echo $main_proj_version | cut -d '/' -f 2) )
    fi
    requireds+=( Required )
fi

###################################################################################
# If we are going to build against installed packages, we need to disable
# the uninstalled .pc files. Otherwise, they are preferred.
###################################################################################

if ([ $install = "true" ] && [ $build = "true" ] || [[ $prefix == $root_dir/* ]]) &&
       [ $disable_uninstalled = "true" ]; then
    export PKG_CONFIG_DISABLE_UNINSTALLED=TRUE
    echo "Disabling uninstalled packages"
fi

###################################################################################
# Finally, go through each project in order and fetch, build, install (as instructed).
# Skip comments (lines starting with '#').
###################################################################################

if [ $write_yaml = true ]; then
    mkdir -p $main_proj_dir/.coin-or
    yaml_file=$main_proj_dir/.coin-or/config.yml
    xml_file=$main_proj_dir/.coin-or/projDesc.xml
    echo "Description:" > $yaml_file
    echo "  Slug: $main_proj" >> $yaml_file 
    echo "  ShortName: $main_proj" >> $yaml_file
    echo "  LongName:" >> $yaml_file
    echo -n "  ShortDescription: " >> $yaml_file
    awk 'BEGIN{on=0} /<projectShortDescription>/{on=1; getline;} /<\/projectShortDescription>/{on=0} {if (on==1) print}' $xml_file | sed 's/^ *//g' >> $yaml_file
    echo "  LongDescription: |2" >> $yaml_file
    tmp=$(awk 'BEGIN{on=0} /<projectDescription>/{on=1} /<\/projectDescription>/{on=0} {if (on==1) print}' $xml_file | sed -e 's/^ */    /g' -e 's/<projectDescription>//' -e 's/"/\\\"/g' -e "s/'/\\\'/g")
    echo "\"$tmp\"" >> $yaml_file
    echo -n "  Manager:" >> $yaml_file
    awk 'BEGIN{on=0} /<projectManager>/{print}' $xml_file | sed -e 's/<projectManager>//' -e 's/<\/projectManager>//' -e 's/^ */ /' >> $yaml_file
    echo "  Homepage: $main_proj_url" >> $yaml_file
    echo "  License: Eclipse Public License 2.0" >> $yaml_file
    echo "  LicenseURL: http://www.opensource.org/licenses/eclipse-2.0" >> $yaml_file
    echo "  Zenodo:" >> $yaml_file
    echo "  Appveyor:" >> $yaml_file
    echo "    Status:" >> $yaml_file
    echo "    Slug:" >> $yaml_file
    echo "  Bintray:" >> $yaml_file
    echo "    Package:" >> $yaml_file
    echo "  Language:" >> $yaml_file
    awk 'BEGIN{on=0} /<projectLanguage>/{print}' $xml_file | sed -e 's/<projectLanguage>//' -e 's/<\/projectLanguage>//' -e 's/^ */    - /g' >> $yaml_file
    echo "  Categories: " >> $yaml_file
#    awk 'BEGIN{on=0} /<category>/{on=1; getline;} /<\/category>/{on=0} {if (on==1) print}' $xml_file | sed 's/^ */    - /g' >> $yaml_file
    awk 'BEGIN{on=0} /<category>/{print}' $xml_file | sed -e 's/<category>//' -e 's/<\/category>//' -e 's/^ */    - /g' >> $yaml_file
    deps=
fi

for ((count=0; count<${#urls[@]}; ++count))
do
    dir=${pdirs[count]}
    url=${urls[count]}
    proj=${projs[count]}
    version=${versions[count]}
    version_num=${version_nums[count]}
    required=${requireds[count]}
    sha=

    case $proj in
        ALPS)
            dir=Alps
            ;;
        BiCePS)
            dir=Bcps
            ;;
        BLIS)
            dir=Blis
            ;;
    esac
    
    if [ $write_yaml = true ] && [ $dir != $main_proj_dir ]; then
        tmp=$(echo $url | sed "s|https://github.com/||" | sed "s|git@github.com:||" | \
                  cut -d "/" -f 2)
        case $(echo $dir | cut -d '/' -f 1) in
            ThirdParty)
                tp_deps+="    - Slug: $tmp"
                tp_deps+=$'\n'
                tp_deps+="      Version: $version_num"
                tp_deps+=$'\n'
                tp_deps+="      Required: Optional"
                tp_deps+=$'\n'
                ;;
            Data)
                data_deps+="    - Slug: $tmp"
                data_deps+=$'\n'
                data_deps+="      Version: $version_num"
                data_deps+=$'\n'
                data_deps+="      Required: Required"
                data_deps+=$'\n'
                ;;
            *)
                coin_deps+="    - Slug: $tmp"
                coin_deps+=$'\n'
                coin_deps+="      Version: $version_num"
                coin_deps+=$'\n'
                ;;
        esac
    fi

    # Get the source (if requested)
    if [ $dir != $main_proj_dir ]; then
        if should_fetch; then
            if [ ! -d $dir ] && [ $fetch != "true" ]; then
                print_action "Warning: project $dir is missing, fetching automatically"
            fi
            fetch_proj
        elif [ $fetch = true ]; then
            if [ -d $dir ]; then 
                print_action "Skipping update of $dir"
            else
                print_action "Skipping $dir"
            fi
        fi
    fi

    if [ $write_yaml = true ] && [ $dir != $main_proj_dir ]; then
        case $dir in
            Data*)
                data_proj=$(echo $dir | cut -d '/' -f 2)
                deps+="  - Description: $data_proj data files"$'\n'
                deps+="    URL: $url"$'\n'
                deps+="    Version: $version_num"$'\n'
                deps+="    Required: Required"$'\n'
                ;;
            ThirdParty*)
                tp_proj=$(echo $dir | cut -d '/' -f 2)
                deps+="  - Description: ThirdParty wrapper for building $tp_proj"$'\n'
                deps+="    URL: $url"$'\n'
                deps+="    Version: $version_num"$'\n'
                deps+="    Required: Optional"$'\n'
                ;;
            BuildTools)
                ;;
            *)
                create_variables $dir/.coin-or/config.yml
                deps+="  - Description: $Description_LongName"$'\n'
                deps+="    URL: $url"$'\n'
                deps+="    Version: $version_num"$'\n'
                deps+="    Required: Required"$'\n'
                ;;
        esac
        
    fi

    #Now set the version number according to the version we currently have checked out
    if [ -d $dir ]; then
        pushd_ $dir
        version_num=$(get_version_git)
        popd_
    else
        continue
    fi

    # Build the project (if requested)
    if [ $build = "true" ] && [ $dir != "BuildTools" ] && [ $dir != "examples" ]; then
        if should_build $dir; then
            build_proj
        fi
    fi

    # Install the project (if requested)
    if ([ $install = "true" ] || ([ $build = "true" ] && [ -w $prefix ])) &&
           [ $dir != "BuildTools" ] && [ $dir != "examples" ]; then
        install_proj
    fi

    # Uninstall the project (if requested)
    if [ $uninstall = "true" ] && [ -e $build_dir/$dir ]; then
        uninstall_proj
    fi
done

if [ $write_yaml = true ]; then
    echo >> $yaml_file
    echo "Dependencies:" >> $yaml_file
    echo -n "$deps"  >> $yaml_file
    echo "  - Description: Basic Linear Algebra Subroutines (BLAS)" >> $yaml_file
    echo "    URL: http://www.netlib.org/blas" >> $yaml_file
    echo "    Required: Recommended" >> $yaml_file
    echo "  - Description: Linear Algebra Package (LAPACK)" >> $yaml_file
    echo "    URL: http://www.netlib.org/lapack" >> $yaml_file
    echo "    Required: Recommended" >> $yaml_file
    echo "  - Description: GNU Readline" >> $yaml_file
    echo "    Required: Recommended" >> $yaml_file
    echo "  - Description: GNU History" >> $yaml_file
    echo "    Required: Recommended" >> $yaml_file
    echo >> $yaml_file
    echo "DevelopmentStatus: " >> $yaml_file
    echo "  activityStatus: Active" >> $yaml_file
    echo "  maturityLevel: 5" >> $yaml_file
    echo "  testedPlatforms: " >> $yaml_file
    echo "  - operatingSystem: Linux" >> $yaml_file
    echo "    compiler: gcc" >> $yaml_file
    echo "  - operatingSystem: "Mac OS X"" >> $yaml_file
    echo "    compiler:" >> $yaml_file
    echo "    - gcc" >> $yaml_file
    echo "    - clang" >> $yaml_file
    echo "  - operatingSystem: Microsoft Windows" >> $yaml_file
    echo "    compiler: cl" >> $yaml_file
    echo "  - operatingSystem: Microsoft Windows with MSys2" >> $yaml_file
    echo "    compiler:" >> $yaml_file
    echo "    - gcc" >> $yaml_file
    echo "    - cl" >> $yaml_file
    echo "    - icl" >> $yaml_file
    echo "  - operatingSystem: Microsoft Windows Subsystem for Linux" >> $yaml_file
    echo "    compiler:" >> $yaml_file
    echo "    - gcc" >> $yaml_file
    echo "    - cl" >> $yaml_file
    echo "    - icl" >> $yaml_file
fi

###################################################################################
# Clean up some directories left by uninstall
###################################################################################

if [ "$prefix" != "" ] && [ $uninstall = "true" ]; then
    sudo=""
    if [ ! -w $prefix ]; then
        if [ ! $(id -u) = 0 ]; then
            sudo=sudo
        fi
    fi
    echo
    echo "Removing $prefix/include/coin and $prefix/share/coin"
    echo
    $sudo rm -rf $prefix/include/coin $prefix/share/coin
fi

###################################################################################
# Run ldconfig to add libraries to cache
###################################################################################

if [ $install = "true" ]; then
    if command -v ld >/dev/null 2>&1; then
        if [[ $(ld --verbose | grep SEARCH_DIR) =~ $prefix/lib ]]; then
            if command -v /sbin/ldconfig >/dev/null 2>&1; then
                echo
                echo "Running ldconfig to update library cache"
                echo
                if command -v sudo >/dev/null 2>&1; then
                    sudo /sbin/ldconfig
                else
                    /sbin/ldconfig
                fi
            fi
        fi
    fi
fi

###################################################################################
# Tell user what to do post-install
###################################################################################

if [ $install = "true" ]; then
    echo
    echo "Install completed. If executing any of the installed"
    echo "binaries results in an error that shared libraries cannot"
    echo "be found, you may need to"
    echo "  - add 'export LD_LIBRARY_PATH=$prefix/lib' to your ~/.bashrc (Linux)"
    echo "  - add 'export DYLD_LIBRARY_PATH=$prefix/lib' to ~/.bashrc (OS X)"
    echo
fi


IFS=$TMP_IFS

