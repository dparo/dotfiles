#!/usr/bin/env bash
# A Linux program to create bootable Windows USB stick from a real Windows DVD or an image
#
# This file is part of WoeUSB.
# https://github.com/WoeUSB/WoeUSB
#
# Copyright © 2013 Colin GILLE / congelli501
# Copyright © 2020 slacka et. al.
# Copyright © 2021 WoeUSB project contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Compatibility notes:
# * realpath: Use `--strip` instead of `--no-symlinks` for realpath(1) for compatibility of Ubuntu 14.04(EoL: April 2019)
# * mktemp: Use short options(-d, -t) for Slackware 14.2 (EoL: Unknown)
#
# lint: We use indirections and primitive variables, which is false positive of this rule
# shellcheck disable=SC2034

# Entry point of the main code
init(){
    check_function_parameters_quantity 1 $#
    local -r program_name="$1"; shift

    local -r application_name='WoeUSB'
    local -r application_version='5.1.2'

    local \
        flag_print_help=false \
        flag_print_version=false \
        flag_print_about=false \

    local -r \
        application_site_url=https://github.com/WoeUSB/WoeUSB \
        application_copyright_declaration="Copyright © Colin GILLE / congelli501 2013\\nCopyright © slacka et.al. 2020" \
        application_copyright_notice="${application_name} is free software licensed under the GNU General Public License version 3(or any later version of your preference) that gives you THE 4 ESSENTIAL FREEDOMS\\nhttps://www.gnu.org/philosophy/"
    local install_mode

    # source_media may be a optical disk drive or a disk image
    # target_media may be an entire usb storage device or just a partition
    local \
        source_media \
        target_media

    local target_partition

    local workaround_bios_boot_flag=false

    local \
        target_filesystem_type=FS_FAT \
        target_fs_label='Windows USB'

    source_fs_mountpoint="$(
        mktemp \
            -d \
            -t \
            woeusb-source-"$(generate_timestamp)".XXXXXX
    )"
    target_fs_mountpoint="$(
        mktemp \
            -d \
            -t \
            woeusb-target-"$(generate_timestamp)".XXXXXX
    )"

    # Parameters that needs to be determined in runtime
    # due to different names in distributions
    declare \
        command_mkdosfs \
        command_mkntfs \
        command_grubinstall \
        name_grub_prefix

    if ! check_runtime_dependencies \
        "${application_name}" \
        command_mkdosfs \
        command_mkntfs \
        command_grubinstall \
        name_grub_prefix; then
        exit 1
    fi

    if ! \
        process_commandline_parameters \
            application_name \
            flag_print_help \
            flag_print_version \
            flag_print_about \
            install_mode \
            source_media \
            target_media \
            target_fs_label \
            workaround_bios_boot_flag \
            target_filesystem_type; then
        print_help \
            "${application_name}" \
            "${application_version}" \
            "${program_name}"
        exit 1

    fi

    process_miscellaneous_requests \
        "${flag_print_help}" \
        "${flag_print_version}" \
        "${flag_print_about}" \
        "${application_name}" \
        "${application_version}" \
        "${application_site_url}" \
        "${application_copyright_declaration}" \
        "${application_copyright_notice}" \
        "${program_name}"

    printf -- \
        '%s\n%s\n' \
        "${application_name} v${application_version}" \
        '=============================='

    check_permission \
        "${application_name}"

    if ! check_runtime_parameters \
        install_mode \
        source_media \
        target_media \
        "${target_fs_label}"; then
        print_help \
            "${application_name}" \
            "${application_version}" \
            "${program_name}"
        exit 1
    fi

    determine_target_parameters \
        "${install_mode}" \
        "${target_media}" \
        target_device \
        target_partition \
        target_filesystem_type

    check_source_and_target_not_busy \
        "${install_mode}" \
        "${source_media}" \
        "${target_device}" \
        "${target_partition}"

    if ! mount_source_filesystem \
        "${source_media}" \
        "${source_fs_mountpoint}"; then
        print_error \
            'Unable to mount source filesystem\n'
        exit 1
    fi

    if [ "${install_mode}" = device ]; then
        wipe_existing_partition_table_and_filesystem_signatures \
            "${target_device}"
        create_target_partition_table \
            "${target_device}" \
            legacy
        create_target_partition \
            "${target_partition}" \
            "${target_filesystem_type}" \
            "${target_fs_label}" \
            "${command_mkdosfs}" \
            "${command_mkntfs}"

        if [ "${target_filesystem_type}" == FS_NTFS ]; then
            create_uefi_ntfs_support_partition \
                "${target_device}"
            install_uefi_ntfs_support_partition \
                "${target_device}2" \
                "${temp_directory}" \
                "${target_device}"
        fi
    fi

    if [ "${install_mode}" = partition ]; then
        check_target_partition \
            "${target_partition}" \
            "${install_mode}" \
            "${target_device}"
    fi

    if ! mount_target_filesystem \
        "${target_partition}" \
        "${target_fs_mountpoint}"  \
        "${target_filesystem_type}"; then
        print_error \
            'Unable to mount target filesystem\n'
        exit 1
    fi

    check_target_filesystem_free_space \
        "${target_fs_mountpoint}" \
        "${source_fs_mountpoint}" \
        || exit 1

    copy_filesystem_files \
        "${source_fs_mountpoint}" \
        "${target_fs_mountpoint}" \
        "${target_filesystem_type}"

    workaround_support_windows_7_uefi_boot \
        "${source_fs_mountpoint}" \
        "${target_fs_mountpoint}"

    install_legacy_pc_bootloader_grub \
        "${target_fs_mountpoint}" \
        "${target_device}" \
        "${command_grubinstall}"

    install_legacy_pc_bootloader_grub_config \
        "${target_fs_mountpoint}" \
        "${name_grub_prefix}"

    if [ "${workaround_bios_boot_flag}" == true ]; then
        workaround_buggy_motherboards_that_ignore_disks_without_boot_flag_toggled \
            "${target_device}"
    fi

    print_info \
        'Done :)\n'
    print_info \
        'The target device should be bootable now\n'

    exit 0
}

print_help(){
    check_function_parameters_quantity 3 "${#}"

    local -r application_name="$1"; shift 1
    local -r application_version="$1"; shift 1
    local -r program_name="$1"

    set +o xtrace
    echo -e "${application_name} ${application_version} Help Information"
    echo -e "======================================"
    echo -e "${application_name} can create a bootable Microsoft Windows(R) USB storage device from an existing Windows optical disk or an ISO disk image."
    echo -e
    echo -e 'Currently two creation methods are supported:'
    echo -e
    echo -e '    --device, -d'
    echo -e
    echo -e '        ''Completely WIPE the entire USB storage device, then build a bootable Windows USB device from scratch.'
    echo -e '        ''WARNING: All previous data on the device will be gone!'
    echo -e
    echo -e '        '"${program_name} --device <source media path> <device>"
    echo -e '        ''Examples:'
    echo -e '        '"- ${program_name} --device Windows7_x64.iso /dev/sdX"
    echo -e '        '"- ${program_name} --device /dev/sr0 /dev/sdX"
    echo -e
    echo -e '    --partition, -p'
    echo -e
    echo -e '        ''Copy Windows files to an existing partition of a USB storage device and make it bootable.  This allows files to coexist as long as no filename conflict exists.'
    echo -e '        ''WARNING: All files that has the same name will be overwritten!'
    echo -e
    echo -e '        '"${program_name} --partition <source media path> <partition>"
    echo -e '        ''Examples:'
    echo -e '        '"- ${program_name} --partition Windows7_x64.iso /dev/sdX1"
    echo -e '        '"- ${program_name} --partition /dev/sr0 /dev/sdX1"
    echo -e
    echo -e '## ''Command-line Options'' ##'
    echo -e '    --verbose, -v'
    echo -e '        ''Verbose mode'
    echo -e
    echo -e '    --help, -h'
    echo -e '        ''Show this help message and exit'
    echo -e
    echo -e '    --version, -V'
    echo -e '        ''Print application version'
    echo -e
    echo -e '    --about, -ab'
    echo -e '        ''Show info about this application'
    echo -e
    echo -e '    --no-color'
    echo -e '        ''Disable message coloring'
    echo -e
    echo -e '    --debug'
    echo -e '        ''Enable script debugging'
    echo -e
    echo -e '    --label, -l <filesystem_label>'
    echo -e '        ''Specify label for the newly created file system in --device creation method'
    echo -e '        ''Note that the label is not verified for validity and may be illegal for the filesystem'
    echo -e
    echo -e '    --workaround-bios-boot-flag'
    echo -e '        '"Workaround BIOS bug that won't include the device in boot menu if non of the partition's boot flag is toggled"
    echo -e
    echo -e '    --debugging-internal-function-call <function name> (function_argument)...'
    echo -e '        ''Development option for developers to test certain function without running the entire build'
    echo -e
    echo -e '    --target-filesystem, --tgt-fs <filesystem name>'
    echo -e '        '"Specify the filesystem to use as the target partition's filesystem."
    echo -e '        ''Currently supported: FAT(default)/NTFS'
    echo -e
    echo -e '    --for-gui'
    echo -e '        ''No longer supported, reserved for compatibility with the wrapper programs'
    echo -e
}

# Print application version then exit, for debugging purpose.
# application_version: Version of the application
print_version(){
    check_function_parameters_quantity 1 $#

    local -r application_version="$1"

    printf -- \
        '%s\n' \
        "${application_version}"
}

print_application_info(){
    check_function_parameters_quantity 5 $#
    local -r application_name="$1"; shift
    local -r application_version="$1"; shift
    local -r application_site_url="$1"; shift
    local -r application_copyright_declaration="$1"; shift
    local -r application_copyright_notice="$1"

    echo "${application_name} ${application_version}"
    echo -e "${application_site_url}"
    echo -e "${application_copyright_declaration}"
    echo -e "${application_copyright_notice}"

}

process_commandline_parameters(){
    check_function_parameters_quantity 10 "${#}"
    local -r application_name="${1}"; shift
    local -n flag_print_help_ref="${1}"; shift
    local -n flag_print_version_ref="${1}"; shift
    local -n flag_print_about_ref="${1}"; shift
    local -n install_mode_ref="${1}"; shift
    local -n source_media_ref="${1}"; shift
    local -n target_media_ref="${1}"; shift
    local -n target_fs_label_ref="${1}"; shift
    local -n workaround_bios_boot_flag_ref="${1}"; shift
    local -n target_filesystem_type_ref="${1}"; shift

    if [ "${#program_args[@]}" -eq 0 ]; then
        flag_print_help_ref=true
        return 0
    fi

    local -a parameters=("${program_args[@]}")
    local \
        enable_debug=false \
        enable_device=false \
        enable_partition=false \
        enable_label=false \
        enable_workaround_bios_boot_flag=false \
        enable_debugging_internal_function_call=false \
        enable_target_filesystem=false

    # Inputs that requires sanitation
    local target_filesystem_type_input

    while [ "${#parameters[@]}" -ne 0 ]; do
        case "${parameters[0]}" in
            --help \
            |-h)
                flag_print_help_ref=true
                return 0
                ;;
            --version \
            |-V)
                flag_print_version_ref=true
                return 0
                ;;
            --about \
            |-ab)
                flag_print_about_ref=true
                return 0
                ;;
            --debug)
                enable_debug=true
                ;;
            --partition \
            |-p)
                enable_partition=true
                install_mode_ref=partition
                shift_array parameters
                if [ "${#parameters[@]}" -lt 2 ]; then
                    print_error \
                        -- \
                        '--partition option requires 2 arguments!\n'
                    return 1
                fi
                source_media_ref="${parameters[0]}"
                shift_array parameters
                target_media_ref="${parameters[0]}"
                ;;
            --device \
            |-d)
                enable_device=true
                # Limitation of ShellCheck to detect usage of indirection variables
                # https://github.com/koalaman/shellcheck/wiki/SC2034
                # shellcheck disable=SC2034
                install_mode_ref=device
                shift_array parameters
                if [ "${#parameters[@]}" -lt 2 ]; then
                    print_error \
                        -- \
                        '--device option requires 2 arguments!'
                    return 1
                fi
                source_media_ref="${parameters[0]}"
                shift_array parameters
                target_media_ref="${parameters[0]}"
                ;;
            --verbose|-v)
                verbose=true
                ;;
            --for-gui)
                no_color=true
                ;;
            --no-color)
                no_color=true
                ;;
            --label|-l)
                enable_label=true
                shift_array parameters
                if [ ${#parameters[@]} -lt 1 ]; then
                    print_error \
                        -- \
                        '--label option requires 1 argument.\n'
                    return 1
                fi
                target_fs_label_ref="${parameters[0]}"
                ;;
            --workaround-bios-boot-flag)
                enable_workaround_bios_boot_flag=true
                workaround_bios_boot_flag_ref=true
                ;;
            --debugging-internal-function-call)
                enable_debugging_internal_function_call=true
                shift_array parameters

                if [ ${#parameters[@]} -lt 1 ]; then
                    print_error \
                        -- \
                        '--debugging-internal-function-call option requires at least 1 argument.\n'
                    return 1
                fi
                "${parameters[@]}"
                exit ${?}
                ;;
            --target-filesystem \
            |--tgt-fs)
                enable_target_filesystem=true

                shift_array parameters
                if [ ${#parameters[@]} -lt 1 ]; then
                    print_error \
                        -- \
                        '--target-filesystem option requires 1 argument.\n'
                    return 1
                fi
                target_filesystem_type_input="$(
                    # Normalize input to uppercase
                    tr \
                        '[:lower:]' \
                        '[:upper:]' \
                    <<< "${parameters[0]}"
                )"
                ;;
            *)
                print_error \
                    'Unknown command-line argument "%s"\n' \
                    "${parameters[0]}"
                return 1
                ;;
        esac
        shift_array parameters
    done

    # None useful action is specified
    if \
        [ "${enable_device}" == false ] \
        && [ "${enable_partition}" == false ] \
        && [ "${enable_debugging_internal_function_call}" == false ]; then
        # intentionally don't mention about the internal function call option
        print_error \
            'No creation method specified!\n'
        return 1
    elif \
        [ "${enable_device}" == true ]  \
        && [ "${enable_partition}" == true ]; then
        print_error \
            -- \
            '--device and --partition creation method are mutual-exclusive.\n'
        return 1
    fi

    # --label option is no use with --partition creation method
    if \
        [ "${enable_partition}" == true ] \
        && [ "${enable_label}" == true ]; then
        print_error \
            -- \
            '--label option only can be used with --device creation method\n'
        return 1
    fi

    # --target-filesystem option is no use with --partition creation method
    if \
        [ "${enable_target_filesystem}" == true ] \
        && [ "${enable_partition}" == true ]; then
        print_error \
            -- \
            '--target-filesystem option only can be used with --device creation method\n'
        return 1
    fi

    # --target-filesystem should be supported
    if \
        [ "${enable_target_filesystem}" = true ]; then
        case "${target_filesystem_type_input}" in
            FAT)
                target_filesystem_type_ref=FS_FAT
            ;;
            NTFS)
                target_filesystem_type_ref=FS_NTFS
            ;;
            *)
                print_error \
                    'Target filesystem not supported.\n'
                return 1
            ;;
        esac
    fi

    if [ "${verbose}" = true ] && [ "${enable_debug}" != true ]; then
        trap 'trap_return "${FUNCNAME[0]}"' RETURN
    fi

    # Always be the last condition so that less debug message from this function will be printed
    if [ "${enable_debug}" = true ]; then
        set -o xtrace
    fi
    return 0
}

process_miscellaneous_requests(){
    check_function_parameters_quantity 9 $#
    local -r flag_print_help="${1}"; shift
    local -r flag_print_version="${1}"; shift
    local -r flag_print_about="${1}"; shift
    local -r application_name="${1}"; shift
    local -r application_version="${1}"; shift
    local -r application_site_url="${1}"; shift
    local -r application_copyright_declaration="${1}"; shift
    local -r application_copyright_notice="${1}"; shift
    local -r program_name="${1}"; shift

    if [ "${flag_print_help}" == true ]; then
        trap - EXIT
        print_help \
            "${application_name}" \
            "${application_version}" \
            "${program_name}"
        exit 0
    fi

    if [ "${flag_print_version}" == true ]; then
        trap - EXIT
        print_version \
            "${application_version}"
        exit 0
    fi

    if [ "${flag_print_about}" == true ]; then
        trap - EXIT
        print_application_info \
            "${application_name}" \
            "${application_version}" \
            "${application_site_url}" \
            "${application_copyright_declaration}" \
            "${application_copyright_notice}"
        exit 0
    fi

}

check_runtime_dependencies(){
    check_function_parameters_quantity 5 $#
    local -r application_name="$1"; shift
    local -n command_mkdosfs_ref="$1"; shift
    local -n command_mkntfs_ref="$1"; shift
    local -n command_grubinstall_ref="$1"; shift
    local -n name_grub_prefix_ref="$1"

    local result=unknown

    for required_command in \
        awk \
        blockdev \
        cut \
        dd \
        df \
        du \
        find \
        grep \
        id \
        lsblk \
        mkdir \
        mount \
        parted \
        partprobe \
        readlink \
        rm \
        stat \
        wget \
        wimlib-imagex \
        wipefs
        do
        if ! command -v "${required_command}" >/dev/null; then
            print_error \
                '%s requires %s command in the executable search path, but it is not found.\n' \
                "${application_name}" \
                "${required_command}"
            result=failed
        fi
    done; unset required_command

    if command -v mkdosfs &> /dev/null; then
        command_mkdosfs_ref=mkdosfs
    elif command -v mkfs.msdos &> /dev/null; then
        command_mkdosfs_ref=mkfs.msdos
    elif command -v mkfs.vfat &>/dev/null; then
        command_mkdosfs_ref=mkfs.vfat
    elif command -v mkfs.fat &>/dev/null; then
        command_mkdosfs_ref=mkfs.fat
    else
        print_error \
            'mkdosfs/mkfs.msdos/mkfs.vfat/mkfs.fat command not found!\n'
        print_error \
            'Please make sure that dosfstools is properly installed!\n'
        result='failed'
    fi

    if command -v mkntfs &>/dev/null; then
        command_mkntfs_ref=mkntfs
    else
        print_error \
            'mkntfs command not found!\n'
        print_error \
            'Please make sure that ntfs-3g is properly installed!\n'
        result=failed
    fi

    if command -v grub-install &> /dev/null; then
        command_grubinstall_ref=grub-install
        name_grub_prefix_ref=grub
    elif command -v grub2-install &> /dev/null; then
        command_grubinstall_ref=grub2-install
        name_grub_prefix_ref=grub2
    else
        print_error \
            'grub-install or grub2-install command not found!\n'
        print_error \
            'Please make sure that GNU GRUB is properly installed!\n'
        result=failed
    fi

    if [ "${result}" == failed ]; then
        return 1
    else
        return 0
    fi
}

check_permission(){
    check_function_parameters_quantity 1 $#
    local -r application_name="$1"

    if [ ! "$(id --user)" = 0 ]; then
        print_warning \
            'You are not running %s as root!\n' \
            "${application_name}"
        print_warning \
            'This might be the reason of the following failure.\n'
    fi
    return 0
}

check_runtime_parameters(){
    check_function_parameters_quantity 4 $#
    local -n install_mode_ref="${1}"; shift
    local -n source_media_ref="${1}"; shift
    local -n target_media_ref="${1}"

    if [ ! -f "${source_media_ref}" ] \
        && [ ! -b "${source_media_ref}" ]; then
        print_error \
            'source media "%s" not found or not a regular file or a block device file!\n' \
            "${source_media_ref}"
        return 1
    fi

    if ! [ -b "${target_media_ref}" ]; then
        print_error \
            'Target media "%s" is not a block device file!\n' \
            "${target_media_ref}"
        return 1
    fi

    if [ "${install_mode_ref}" = device ] \
        && [[ "${target_media}" =~ .*[0-9] ]]
        then
        print_error \
            'Target media "%s" is not an entire storage device!\n' \
            "${target_media_ref}"
        return 1
    fi

    if [ "${install_mode_ref}" = partition ] \
        && ! [[ "${target_media}" =~ .*[0-9] ]]
        then
        print_error \
            'Target media "%s" is not an partition!\n' \
            "${target_media_ref}"
        return 1
    fi

    return 0
}

determine_target_parameters(){
    check_function_parameters_quantity 5 $#
    local install_mode="${1}"; shift
    local target_media="${1}"; shift
    local -n target_device_ref="${1}"; shift
    local -n target_partition_ref="${1}"; shift
    local -n target_filesystem_type_ref="${1}"; shift

    if [ "${install_mode}" = partition ]; then
        local target_filesystem_type_libblkid

        target_partition_ref="${target_media}"
        # BASHDOC: Basic Shell Features » Shell Expansions » Shell Parameter Expansion(`${PARAMETER/PATTERN/STRING}')
        target_device_ref="${target_media/%[0-9]/}"

        # Detect target filesystem
        target_filesystem_type_libblkid="$(
                lsblk \
                    --noheadings \
                    --output FSTYPE \
                    "${target_partition_ref}"
        )"

        case "${target_filesystem_type_libblkid}" in
            vfat)
                target_filesystem_type_ref=FS_FAT
            ;;
            ntfs)
                target_filesystem_type_ref=FS_NTFS
            ;;
            *)
                print_error \
                    'Unsupported target filesystem "%s", currently supported target filesystems: %s, %s' \
                    "${target_filesystem_type_libblkid}" \
                    "${ENUM_SUPPORTED_FILESYSTEMS[FS_FAT]}" \
                    "${ENUM_SUPPORTED_FILESYSTEMS[FS_NTFS]}"
                return 1
            ;;
        esac
        unset target_filesystem_type_libblkid
    else # install_mode = device
        target_device_ref="${target_media}"
        target_partition_ref="${target_device}1"
    fi

    if [ "${verbose}" = true ]; then
        print_info \
            "Target device is '%s'.\\n" \
            "${target_device_ref}"
        print_info \
            "Target partition is '%s'.\\n" \
            "${target_partition_ref}"
        if [ "${install_mode}" = partition ]; then
            print_info \
                "Target filesystem is '%s'.\\n" \
                "${ENUM_SUPPORTED_FILESYSTEMS[$target_filesystem_type]}"
        fi
    fi
    return 0
}

is_target_busy(){
    check_function_parameters_quantity 1 $#
    local device="${1}"

    if [ "$(mount \
            | grep \
            --count \
            --fixed-strings\
            "${device}"
        )" -ne 0 ]; then
        return 0
    else
        return 1
    fi
}

check_source_and_target_not_busy(){
    check_function_parameters_quantity 4 $#
    local install_mode="$1"; shift
    local source_media="$1"; shift
    local target_device="$1"; shift
    local target_partition="$1"

    if [ "$(mount \
            | grep \
            --count \
            --fixed-strings \
            "${source_media}"
        )" != 0 ]; then
        print_error \
            'Source media is currently mounted, unmount the partition then try again\n'
        exit 1
    fi

    if [ "${install_mode}" = partition ]; then
        if [ "$(mount \
                | grep \
                --count \
                --fixed-strings \
                "${target_partition}"
            )" != 0 ]; then
            print_error \
                'Target partition is currently mounted, unmount the partition then try again\n'
            exit 1
        fi
    else # When install_mode = device, all target partitions needs to by unmounted
        if is_target_busy "${target_device}"; then
            print_error \
                'Target device is currently busy, unmount all mounted partitions in target device then try again\n'
            exit 1
        fi
    fi
}

wipe_existing_partition_table_and_filesystem_signatures(){
    check_function_parameters_quantity 1 $#
    local -r target_device="${1}"

    print_info \
        'Wiping all existing partition table and filesystem signatures in %s...\n' \
        "${target_device}"
    wipefs --all "${target_device}"

    check_if_the_drive_is_really_wiped \
        "${target_device}"

    return $?
}

# Some broken locked-down flash drive will appears to be successfully wiped but actually nothing is written into it and will shown previous partition scheme afterwards.  This is the detection of the case and will bail out if such things happened
# target_device: The target device file to be checked
check_if_the_drive_is_really_wiped(){
    check_function_parameters_quantity 1 $#
    local -r target_device="$1"

    print_info \
        'Ensure that %s is really wiped...\n' \
        "${target_device}"

    if [ "$(
        env LANG=C \
            lsblk \
                --noheadings \
                --output TYPE \
                "${target_device}" \
            | grep \
                --count \
                --fixed-strings \
                part
        )" -ne 0 ]; then
        print_error \
            'Partition is still detected after wiping all signatures, this indicates that the drive might be locked into readonly mode due to end of lifespan.\n'
        return 1
    else
        return 0
    fi
}

create_target_partition_table(){
    check_function_parameters_quantity 2 $#
    local -r target_device="${1}"; shift
    local -r partition_table_type="${1}"

    print_info \
        'Creating new partition table on %s...\n' \
        "${target_device}"

    local parted_partiton_table_argument

    case "${partition_table_type}" in
        legacy|msdos|mbr|pc)
            parted_partiton_table_argument=msdos
            ;;
        gpt|guid)
            parted_partiton_table_argument=gpt
            print_error \
                'Currently GUID partition table is not supported.\n'
            return 2
            ;;
        *)
            print_error \
                'Partition table not supported.\n'
            return 2
            ;;
    esac

    # Create partition table(and overwrite the old one, whatever it was)
    parted --script \
        "${target_device}" \
        mklabel \
        "${parted_partiton_table_argument}"
}

# NOTE: This really should be done automatically by GNU Parted after every operation
workaround_make_system_realize_partition_table_changed(){
    check_function_parameters_quantity 1 $#
    local -r target_device="$1"

    print_info \
        'Making system realize that partition table has changed...'

    blockdev \
        --rereadpt \
        "${target_device}" \
        || true
    print_info \
        'Wait 3 seconds for block device nodes to populate...'
    sleep 3

}

create_target_partition(){
    check_function_parameters_quantity 5 $#
    local -r target_partition="$1"; shift

    # ENUM_SUPPORTED_FILESYSTEMS
    local -r filesystem_type="$1"; shift

    local -r filesystem_label="$1"; shift
    local -r command_mkdosfs="$1"; shift
    local -r command_mkntfs="$1"

    # Refer: GNU Parted's (info) manual: Using Parted » Command explanations » mkpart
    # Refer: sudo parted --script /dev/sda help mkpart
    local parted_mkpart_fs_type
    case "${filesystem_type}" in
        FS_FAT)
            parted_mkpart_fs_type=fat32
            ;;
        FS_NTFS)
            parted_mkpart_fs_type=ntfs
            ;;
        *)
            print_error \
                'Filesystem not supported\n'
            return 2
            ;;
    esac

    print_info \
        'Creating target partition...'

    # Create target partition
    # We start at 4MiB for grub (it needs a post-mbr gap for its code) and alignment of flash memery block erase segment in general, for details see http://www.gnu.org/software/grub/manual/grub.html#BIOS-installation and http://lwn.net/Articles/428584/
    # If NTFS filesystem is used we leave a 512KiB partition at the end for installing UEFI:NTFS partition for NTFS support
    case "${parted_mkpart_fs_type}" in
        fat32)
            parted --script \
                "${target_device}" \
                mkpart \
                primary \
                "${parted_mkpart_fs_type}" \
                4MiB \
                -- -1s # last sector of the disk
            ;;
        ntfs)
            # Major partition for storing user files
            # NOTE: Microsoft Windows has a bug that only recognize the first partition for removable storage devices, that's why this partition should always be the first one
            parted --script \
                "${target_device}" \
                mkpart \
                primary \
                "${parted_mkpart_fs_type}" \
                4MiB \
                -- -1025s # Leave 512KiB==1024sector in traditional 512bytes/sector disk, disks with sector with more than 512bytes only result in partition size greater than 512KiB and is intentionally let-it-be.
                # FIXME: Leave exact 512KiB in all circumstances is better, but the algorithm to do so is quite brainkilling.
            ;;
        *)
            print_fatal \
                'Illegal parted_mkpart_fs_type, please report bug.\n'
            ;;
    esac
    unset parted_mkpart_fs_type

    workaround_make_system_realize_partition_table_changed \
        "${target_device}"

    # Format target partition's filesystem
    case "${filesystem_type}" in
        FS_FAT)
            "${command_mkdosfs}" \
                -F 32 \
                -n "${filesystem_label}" \
                "${target_partition}"
            ;;
        FS_NTFS)
            "${command_mkntfs}" \
                --quick \
                --label "${filesystem_label}" \
                "${target_partition}"
            ;;
        *)
            print_fatal \
                "Shouldn't be here\\n"
            exit 1
            ;;
    esac
}

# Create UEFI:NTFS partition to support booting UEFI bootloader in NTFS filesystem where some UEFI firmwares are not able to do so
# https://github.com/pbatard/uefi-ntfs
# This routine assumes that there's only one partition on the disk, and the trailing 512KiB space is not partitioned
# This routine should be run after create_target_partition and only on target partition's filesystem is NTFS
# target_device: The target device's entire deice file
create_uefi_ntfs_support_partition(){
    check_function_parameters_quantity 1 $#

    local -r target_device="$1"

    # FIXME: The partition type should be `fat12` but `fat12` isn't recognized by Parted...
    # NOTE: The --align is set to none because this partition is indeed misaligned, but ignored due to it's small size
    parted \
        --align none \
        --script \
        "${target_device}" \
        mkpart \
        primary \
        fat16 \
        --  \
        -1024s \
        -1s

    return "$?"
}

# Install UEFI:NTFS partition by writing the partition image into the created partition
# FIXME: Currently this requires internet access to download the image from GitHub directly, it should be replaced by including the image in our datadir
# uefi_ntfs_partition: The previously allocated partition for installing UEFI:NTFS, requires at least 512KiB
# download_directory: The temporary directory for downloading UEFI:NTFS image from GitHub
# target_device: For workaround_make_system_realize_partition_table_changed
install_uefi_ntfs_support_partition(){
    check_function_parameters_quantity 3 $#

    local -r uefi_ntfs_partition="$1"; shift
    local -r download_directory="$1"; shift
    local -r target_device="$1"

    if ! wget \
        --directory-prefix="${download_directory}" \
        https://github.com/pbatard/rufus/raw/master/res/uefi/uefi-ntfs.img; then
        print_warning \
            "Unable to download UEFI:NTFS partition image from GitHub, installation skipped.  Target device might not be bootable if the UEFI firmware doesn't support NTFS filesystem.\\n"
        return 0
    fi

    # Write partition image to partition
    dd \
        if="${download_directory}/uefi-ntfs.img" \
        of="${uefi_ntfs_partition}"

}

# Some buggy BIOSes won't put detected device with valid MBR but no partitions with boot flag toggled into the boot menu, workaround this by setting the first partition's boot flag(which partition doesn't matter as GNU GRUB doesn't depend on it anyway
workaround_buggy_motherboards_that_ignore_disks_without_boot_flag_toggled(){
    check_function_parameters_quantity 1 $#

    local -r target_device="$1"

    print_warning \
        'Applying workaround for buggy motherboards that will ignore disks with no partitions with the boot flag toggled\n'
    parted --script \
        "${target_device}" \
        set 1 boot on

    return $?
}

# Check target partition for potential problems before mounting them for --partition creation mode as we don't know about the existing partition
# target_partition: The target partition to check
# install_mode: The usb storage creation method to be used
# target_device: The parent device of the target partition, this is passed in to check UEFI:NTFS filesystem's existence on check_uefi_ntfs_support_partition
check_target_partition(){
    check_function_parameters_quantity 3 $#
    local target_partition="${1}"; shift
    local install_mode="${1}"; shift
    local target_device="${1}"

    local target_filesystem
    target_filesystem="$(
        lsblk \
            --output FSTYPE \
            --noheadings \
            "${target_partition}"
    )"

    case "${target_filesystem}" in
        vfat)
            : # supported
            ;;
        ntfs)
            check_uefi_ntfs_support_partition \
                "${target_device}"
            ;;
        *)
            print_error \
                'Target filesystem not supported, currently supported filesystem: FAT, NTFS.\n'
            return 1
            ;;
    esac
    return 0
}

# Check if the UEFI:NTFS support partition exists
# Currently it depends on the fact that this partition has a label of "UEFI_NTFS"
# target_device: The UEFI:NTFS partition residing entier device file
check_uefi_ntfs_support_partition(){
    check_function_parameters_quantity 1 $#

    local -r target_device="$1"

    if \
        ! \
        lsblk \
            --output LABEL \
            --noheadings \
            "${target_device}" \
        | grep \
            --fixed-strings \
            --silent \
            'UEFI_NTFS'; then
        print_warning \
            "Your device doesn't seems to have an UEFI:NTFS partition, UEFI booting will fail if the motherboard firmware itself doesn't support NTFS filesystem!\\n"
        print_info \
            'You may recreate disk with an UEFI:NTFS partition by using the --device creation method\n'
    fi
}

mount_source_filesystem(){
    check_function_parameters_quantity 2 $#
    local source_media="$1"; shift
    local source_fs_mountpoint="$1"

    print_info \
        'Mounting source filesystem...\n'

    mkdir \
        --parents \
        "${source_fs_mountpoint}" \
        || (
            print_error \
                'Unable to create "%s" mountpoint directory\n' \
                "${source_fs_mountpoint}"
            return 1
        )
    if [ -f "${source_media}" ]; then # ${source_media} is an ISO image
        mount \
            --options loop,ro \
            --types udf,iso9660 \
            "${source_media}" \
            "${source_fs_mountpoint}" \
        || (
            print_error \
                'Unable to mount source media\n'
            return 1
        )
    else # ${source_media} is a real optical disk drive (block device)
        mount \
            --options ro \
            "${source_media}" \
            "${source_fs_mountpoint}" \
        || (
            print_error \
                'Unable to mount source media\n'
            return 1
        )
    fi
}

# Mount target filesystem to existing path as mountpoint
# target_partition: The partition device file target filesystem resides, for example /dev/sdX1
# target_fs_mountpoint: The existing directory used as the target filesystem's mountpoint, for example /mnt/target_filesystem
# target_fs_type: The filesystem of the target filesystem currently supports: FAT, NTFS
mount_target_filesystem(){
    check_function_parameters_quantity 3 $#
    local target_partition="$1"; shift
    local target_fs_mountpoint="$1"; shift

    # ENUM_SUPPORTED_FILESYSTEMS
    local target_fs_type="$1"

    print_info \
        'Mounting target filesystem...\n'

    mkdir \
        --parents \
        "${target_fs_mountpoint}" \
        || (
            print_error \
                'Unable to create "%s" mountpoint directory\n' \
                "${target_fs_mountpoint}"
            return 1
        )

    # Determine proper mount options according to filesystem type
    local mount_options='defaults'
    local fstype_options=''

    case "${target_fs_type}" in
        FS_FAT)
            mount_options+=',utf8=1'
            fstype_options="-t vfat"
        ;;
        FS_NTFS)
            fstype_options="-t ntfs-3g"
        ;;
        *)
            print_fatal \
                'Unsupported target_fs_type, please report bug.\n'
            exit 1
        ;;
    esac

    # false-positive: The fstype_options are expected to be expanded verbatim
    # shellcheck disable=SC2086
    mount \
        --options "${mount_options}" \
        ${fstype_options} \
        "${target_partition}" \
        "${target_fs_mountpoint}" \
        || (
            print_error \
                'Unable to mount target partition\n'
            return 1
        )
}

check_target_filesystem_free_space(){
    check_function_parameters_quantity 2 $#
    local -r target_fs_mountpoint="${1}"; shift
    local -r source_fs_mountpoint="${1}"

    free_space=$(
        df \
            --block-size=1 \
            "${target_fs_mountpoint}" \
        | grep \
            --fixed-strings \
            "${target_fs_mountpoint}" \
        | awk '{print $4}'
    )
    free_space_human_readable=$(
        df \
            --human-readable \
            "${target_fs_mountpoint}" \
        | grep \
            --fixed-strings \
            "${target_fs_mountpoint}" \
        | awk '{print $4}'
    )
    needed_space=$(
        du \
            --summarize \
            --bytes \
            "${source_fs_mountpoint}" \
        | awk '{print $1}'
    )
    needed_space_human_readable=$(
        du \
            --summarize \
            --human-readable \
            "${source_fs_mountpoint}" \
        | awk '{print $1}'
    )
    additional_space_required_for_grub_installation="$((1000 * 1000 * 10))" # 10MiB
    ((needed_space = needed_space + additional_space_required_for_grub_installation))

    if [ "${needed_space}" -gt "${free_space}" ]; then
        print_error \
            'Not enough free space on target partition!'
        print_error \
            "We required %s(%u bytes) but '%s' only has %s(%u bytes)." \
            "${needed_space_human_readable}" \
            "${needed_space}" \
            "${target_partition}" \
            "${free_space_human_readable}" \
            "${free_space}"
        return 1
    fi
}

# Copying all files from one filesystem to another, with progress reporting
copy_filesystem_files(){
    check_function_parameters_quantity 3 "${#}"
    local source_fs_mountpoint="${1}"; shift
    local target_fs_mountpoint="${1}"; shift
    local target_filesystem_type="${1}"; shift

    local -i total_size
    total_size=$(
        du \
            --summarize \
            --bytes \
            "${source_fs_mountpoint}" \
        | awk '{print $1}'
    )

    print_info \
        'Copying files from source media...\n'

    pushd "${source_fs_mountpoint}" >/dev/null

    local -i copied_size=0 percentage; while IFS='' read -r -d '' source_file; do
        dest_file="${target_fs_mountpoint}/${source_file}"

        source_file_size=$(
            stat \
                --format=%s \
                "${source_file}"
        )

        if [ -d "${source_file}" ]; then
            mkdir --parents "${dest_file}"
        elif [ -f "${source_file}" ]; then
            if [ "${verbose}" = true ]; then
                print_info \
                    'Copying "%s"...\n' \
                    "${source_file}"
            fi
            if [ "${source_file_size}" -lt "${DD_BLOCK_SIZE}" ]; then
                cp "${source_file}" "${dest_file}"
            else
                # FS_FAT is not a parameter expansion
                # shellcheck disable=SC2050
                if [ "${target_filesystem_type}" == FS_FAT ] \
                    && [ "${source_file_size}" -gt "${FAT32_FILESIZE_LIMIT}" ]; then
                    if [[ ! "${source_file}" =~ \.wim$ ]]; then
                        print_warning \
                            'Unsupported oversized file "%s" detected, this file will NOT be transferred.\n' \
                            "${source_file}"
                    else
                        copy_oversized_wim_file \
                            "${source_file}" \
                            "${dest_file}" \
                            "${copied_size}" \
                            "${total_size}"
                    fi
                else
                    copy_large_file \
                        "${source_file}" \
                        "${dest_file}" \
                        "${copied_size}" \
                        "${total_size}"
                fi
            fi
        else
            print_error \
                "Unknown type of '%s'!\\n"
                "${source_file}"
            exit 1
        fi

        # Calculate and report progress
        # BASHDOC: Basic Shell Features » Shell Expansions » Arithmetic Expansion
        # BASHDOC: Bash Features » Shell Arithmetic
        ((copied_size = copied_size + source_file_size)) || true
        ((percentage = (copied_size * 100) / total_size)) || true
        echo -en "${percentage}%\\r"
    done < <( \
        find \
            . \
            -not -path "." \
            -print0 \
    ); unset source_file dest_file source_file_size copied_size percentage

    popd >/dev/null

    return 0
}

# Companion function of copy_filesystem_files for copying large files
# Copy source_file to dest_file, overwrite file if dest_file exists
# Also report copy_filesystem_files progress during operation
copy_large_file(){
    check_function_parameters_quantity 4 "${#}"
    local -r source_file="${1}"; shift
    local -r dest_file="${1}"; shift
    local -ir caller_copied_size="${1}"; shift
    local -ir caller_total_size="${1}"

    local -i source_file_size
    source_file_size=$(
        stat \
        --format=%s \
        "${source_file}"
    )

    # block count of the source file
    local -i block_number
    ((block_number = source_file_size / DD_BLOCK_SIZE + 1))
    unset source_file_size

    if [ -f "${dest_file}" ]; then
        rm "${dest_file}"
    fi

    # Copy file block by block
    local -i i=0 copied_size_total percentage; while [ "${i}" -lt "${block_number}" ]; do
        dd \
            if="${source_file}" \
            bs="${DD_BLOCK_SIZE}" \
            skip="${i}" \
            seek="${i}" \
            of="${dest_file}" \
            count=1 \
            2> /dev/null
        ((i = i + 1))

        # Calculate and report progress
        # BASHDOC: Basic Shell Features » Shell Expansions » Arithmetic Expansion
        # BASHDOC: Bash Features » Shell Arithmetic
        ((copied_size_total = caller_copied_size + DD_BLOCK_SIZE * i)) || true
        ((percentage = (copied_size_total * 100) / caller_total_size)) || true
        echo -en "${percentage}%\\r"
    done; unset i copied_size_total percentage

    return 0
}

# Copy WIM files that is over 4GiB to a FAT32 filesystem
# Using wimlib to split file into smaller parts
copy_oversized_wim_file(){
    check_function_parameters_quantity 4 "${#}"
    local source_file="${1}"; shift
    local dest_file="${1}"; shift
    local -ir caller_copied_size="${1}"; shift
    local -ir caller_total_size="${1}"; shift

    local dest_file_basename="${dest_file%.wim}"

    # Split WIM image using wimtools to fit FAT32 restriction
    # Optimal split file size: 4GiB - 1MiB = 4095MiB
    wimlib-imagex split \
        "${source_file}" \
        "${dest_file_basename}.swm" \
        4095 \
        &

    # We simulate progress report via sum-up the destination files
    local -i \
        splitted_files_size_total=0 \
        splitted_file_size=0 \
        copied_size_current="${caller_copied_size}" \
        percentage_current=0
    wimlib_imagex_pid="${!}"
    while kill -0 "${wimlib_imagex_pid}" 2>/dev/null; do
        splitted_files_size_total=0
        splitted_file_size=0
        copied_size_current="${caller_copied_size}"
        is_dest_file_available=false

        # Ensure swm file is created by wimlib before accounting sizes
        while test "${is_dest_file_available}" == false && \
                ! test -e "${dest_file_basename}".swm; do
            sleep 1
        done
        is_dest_file_available=true

        for splitted_file in "${dest_file_basename}"*.swm; do
            splitted_file_size="$(
                stat \
                    --format=%s \
                    "${splitted_file}"
            )"
            (( splitted_files_size_total += splitted_file_size ))
        done
        (( copied_size_current += splitted_files_size_total ))
        (( percentage = (copied_size_current * 100) / caller_total_size))
        echo -en "${percentage}%\\r"

        # Use less resource during accounting sizes
        sleep 0.2s
    done

    # Let EXIT trap know the process ended so that it won't try to
    # kill random processes
    wimlib_imagex_pid=
}

# As Windows 7's installation media doesn't place the required EFI
# bootloaders in the right location, we extract them from the
# system image manually
# TODO: Functionize Windows 7 checking
workaround_support_windows_7_uefi_boot(){
    check_function_parameters_quantity 2 "${#}"
    local source_fs_mountpoint="${1}"; shift
    local target_fs_mountpoint="${1}"

    # Apply workaround only if the source is based on Windows 7, and EFI version of bootmgr is in place
    if ! grep \
            --extended-regexp \
            --quiet \
            '^MinServer=7[0-9]{3}\.[0-9]' \
            "${source_fs_mountpoint}/sources/cversion.ini" \
        || ! [ -f "${source_fs_mountpoint}/bootmgr.efi" ]; then
        return 0
    fi

    print_warning \
        'Source media seems to be Windows 7-based with EFI support, applying workaround to make it support UEFI booting\n'
    if ! command -v '7z' >/dev/null 2>&1; then
        print_warning \
            "'7z' utility not found, workaround is not applied.\\n"
        return 0
    fi

    # Detect **case-insensitive** existing efi directories according to UEFI spec
    local \
        test_efi_directory \
        efi_directory
    test_efi_directory="$(
        find \
            "${target_fs_mountpoint}" \
            -ipath "${target_fs_mountpoint}/efi"
    )"
    if [ -z "${test_efi_directory}" ]; then
        efi_directory="${target_fs_mountpoint}/efi"
        if [ "${verbose}" = true ]; then
            print_debug \
                "Can't find efi directory, use %s.\\n" \
                "${efi_directory}"
        fi
    else # efi directory(case don't care) exists
        efi_directory="${test_efi_directory}"
        if [ "${verbose}" = true ]; then
            print_debug \
                '%s detected.\n' \
                "${efi_directory}"
        fi
    fi
    unset test_efi_directory

    local \
        test_efi_boot_directory \
        efi_boot_directory
    test_efi_boot_directory="$(
        find \
            "${target_fs_mountpoint}" \
            -ipath "${efi_directory}/boot"
    )"
    if [ -z "${test_efi_boot_directory}" ]; then
        efi_boot_directory="${efi_directory}/boot"
        if [ "${verbose}" = true ]; then
            print_debug \
                "Can't find efi/boot directory, use %s.\\n" \
                "${efi_boot_directory}"
        fi
    else # boot directory(case don't care) exists
        efi_boot_directory="${test_efi_boot_directory}"
        if [ "${verbose}" = true ]; then
            print_debug \
                '%s detected.\n' \
                "${efi_boot_directory}"
        fi
    fi
    unset \
        efi_directory \
        test_efi_boot_directory

    # If there's already an EFI bootloader existed, skip the workaround
    local test_efi_bootloader
    test_efi_bootloader="$(
        find \
            "${target_fs_mountpoint}" \
            -ipath "${target_fs_mountpoint}/efi/boot/boot*.efi"
    )"
    if [ -n "${test_efi_bootloader}" ]; then
        print_info \
            'Detected existing EFI bootloader, workaround skipped.\n'
        return 0
    fi

    mkdir \
        --parents \
        "${efi_boot_directory}"

    # Skip workaround if EFI bootloader already exist in efi_boot_directory
    7z \
        e \
        -so \
        "${source_fs_mountpoint}/sources/install.wim" \
        "Windows/Boot/EFI/bootmgfw.efi" \
        > "${efi_boot_directory}/bootx64.efi"
}

install_legacy_pc_bootloader_grub(){
    check_function_parameters_quantity 3 "${#}"
    local -r target_fs_mountpoint="${1}"; shift 1
    local -r target_device="${1}"; shift 1
    local -r command_grubinstall="${1}"

    print_info \
        'Installing GRUB bootloader for legacy PC booting support...\n'
    "${command_grubinstall}" \
        --target=i386-pc \
        --boot-directory="${target_fs_mountpoint}" \
        --force "${target_device}"


}

# Install a GRUB config file to chainload Microsoft Windows's bootloader in Legacy PC bootmode
# target_fs_mountpoint: Target filesystem's mountpoint(where GRUB is installed)
# name_grub_prefix: May be different between distributions, so need to be specified (grub/grub2)
install_legacy_pc_bootloader_grub_config(){
    check_function_parameters_quantity 2 $#

    local -r target_fs_mountpoint="$1"; shift
    local -r name_grub_prefix="$1"

    print_info \
        'Installing custom GRUB config for legacy PC booting...\n'
    local -r grub_cfg="${target_fs_mountpoint}/${name_grub_prefix}/grub.cfg"
    local target_fs_uuid; target_fs_uuid=$(
        lsblk \
            --noheadings \
            --raw \
            --output UUID,MOUNTPOINT \
        | grep \
            --extended-regexp \
            "${target_fs_mountpoint}"$ \
        | cut \
            --fields=1 \
            --delimiter=' '
    )

    mkdir --parents "$(dirname "${grub_cfg}")"
    {
        # SC1040 workaround
        # https://github.com/koalaman/shellcheck/wiki/SC1040
        cat <<- END_OF_FILE
            ntldr /bootmgr
            boot
END_OF_FILE
    } > "${grub_cfg}"; unset target_fs_uuid
}

# Unmount mounted filesystem and clean-up mountpoint before exiting program
# return_value: 1 - Failed to unmount / 2 - Failed to remove mountpoint
cleanup_mountpoint(){
    check_function_parameters_quantity 1 "${#}"
    local -r fs_mountpoint="${1}"; shift

    # In copy_filesystem_files, we use `pushd` to changed the working
    # directory into source_fs_mountpoint in order to get proper source
    # and target file path, proactively `popd` to ensure we are not in
    # source_fs_mountpoint and preventing source filesystem to unmount
    popd &>/dev/null \
        || true

    if [ -e "${fs_mountpoint}" ]; then
        print_info \
            'Unmounting and removing "%s"...\n' \
            "${fs_mountpoint}"
        if ! umount "${fs_mountpoint}"; then
            print_warning \
                'Unable to unmount "%s".\n' \
                "${fs_mountpoint}"
            return 1
        fi

        if ! rmdir "${fs_mountpoint}"; then
            print_warning \
                'Unable to remove "%s".\n' \
                "${fs_mountpoint}"
            return 2
        fi
    fi

    return 0
}

# Traps: Functions that are triggered when certain condition occurred
# Shell Builtin Commands » Bourne Shell Builtins » trap
trap_errexit(){
    print_error \
        'The command "%s" failed with exit status "%u", program is prematurely aborted\n'\
        "${BASH_COMMAND}" \
        "${?}"

    return 0
}

trap_exit(){
    # Mountpoints aren't successfully removed
    local flag_unclean=false

    # Target filesystem failed to unmount
    local flag_unsafe=false

    if [ -n "${wimlib_imagex_pid}" ]; then
        kill -s SIGKILL "${wimlib_imagex_pid}" || true
        # Ensure fs is inactive before unmount
        sleep 1
    fi

    if util_is_parameter_set_and_not_empty \
        source_fs_mountpoint; then
        if ! cleanup_mountpoint  \
            "${source_fs_mountpoint}"; then
            flag_unclean=true
        fi
    fi

    if util_is_parameter_set_and_not_empty \
        target_fs_mountpoint; then
        if ! cleanup_mountpoint \
            "${target_fs_mountpoint}"; then
            local -i return_value="${?}"

            flag_unclean=true

            if [ "${return_value}" = 1 ]; then
                flag_unsafe=true
            fi
        fi
    fi

    if [ "${flag_unclean}" = true ]; then
        print_warning \
            'Some mountpoints are not unmount/cleaned successfully and must be done manually\n'
    fi

    if [ "${flag_unsafe}" = true ]; then
        print_warning \
            'We unable to unmount target filesystem for you, please make sure target filesystem is unmounted before detaching to prevent data corruption\n'
    fi

    unset \
        flag_unclean \
        flag_unsafe

    if \
        util_is_parameter_set_and_not_empty\
            target_device; then
        if is_target_busy "${target_device}"; then
            print_warning \
                'Target device is busy, please make sure you unmount all filesystems on target device or shutdown the computer before detaching it.\n'
        else
            print_info \
                'You may now safely detach the target device\n'
        fi
    fi

    rm \
        --recursive \
        "${temp_directory}"

    return 0
}

trap_interrupt(){
    printf '\n' # Separate message with previous output
    print_warning \
        'Recieved SIGINT, program is interrupted.\n'
    return 1
}

trap_return(){
    check_function_parameters_quantity 1 "${#}"
    local returning_function="${1}"

    for ignored_function in \
        check_function_parameters_quantity \
        util_is_parameter_set_and_not_empty \
        switch_terminal_text_color \
        printf_with_color \
        print_info \
        print_warning \
        print_error \
        print_fatal \
        print_debug; do
        if [ "${returning_function}" == "${ignored_function}" ]; then
            return 0
        fi
    done

    print_debug \
        'returning from %s\n' \
        "${returning_function}"
}

# An utility function for inhibiting command call output and
# only show them to user when error occurred
util_call_external_command(){
    local -ar command=("${@}")

    local command_output
    local -i command_exit_status
    if command_output="$( "${command[@]}" 2>&1 )"; then
        command_exit_status=0
    else
        command_exit_status="$?"
    fi

    if [ "${command_exit_status}" -ne 0 ]; then
        print_error \
            'Error occurred while running command "%s" (exit status: %u)!\n' \
            "${command[*]}" \
            "${command_exit_status}"

        local -r read_prompt="Read command output (Y/n)?"
        printf '%s' "${read_prompt}"

        local answer=y

        while true; do
            read -r answer

            if [ "${answer}" == y ] || [ "${answer}" == Y ]; then
                echo "${command_output}"
                break
            elif [ "${answer}" == n ] || [ "${answer}" == N ]; then
                break
            else
                printf '%s' "${read_prompt}"
            fi
        done

        print_error \
            'Press ENTER to continue\n'
        read -r # catch enter key
    fi

    return "${command_exit_status}"
}

# Configure the terminal to print future messages with certain color
# Parameters:
# - color: color of the next message, or `none` to reset to default color
switch_terminal_text_color(){
    check_function_parameters_quantity 1 $#
    local -r color="$1"

    case "${color}" in
        black)
            echo -en '\033[0;30m'
            ;;
        red)
            echo -en '\033[0;31m'
            ;;
        green)
            echo -en '\033[0;32m'
            ;;
        yellow)
            echo -en '\033[0;33m'
            ;;
        blue)
            echo -en '\033[0;34m'
            ;;
        white)
            echo -en '\033[0;37m'
            ;;
        none)
            tput sgr0
            ;;
        *)
            print_fatal \
                'Illegal parameter, please report bug.\n'
            exit 1
            ;;
    esac
}

# Print formatted message with color
printf_with_color(){
    if [ ${#} -lt 2 ]; then
        print_fatal \
            'Parameter quantity illegal, please report bug.\n'
        exit 1
    fi
    local -r color="${1}"; shift
    local -ar printf_parameters=("${@}")

    if [ "${no_color}" == true ]; then
        # False positive: not format string(ShellCheck #1028)
        # shellcheck disable=SC2059
        printf -- \
            "${printf_parameters[@]}"
    else # no_color = false
        switch_terminal_text_color "${color}"
        # False positive: not format string(ShellCheck #1028)
        # shellcheck disable=SC2059
        printf -- \
            "${printf_parameters[@]}"
        switch_terminal_text_color none
    fi
}

print_fatal(){
    local -a printf_arguments=("${@}")

    if test "${#printf_arguments[@]}" -eq 0; then
        printf \
            '%s: FATAL: This function should have at least 1 argument.\n' \
            "${FUNCNAME[0]}" \
            1>&2
        exit 1
    fi

    printf \
        '%s: FATAL: ' \
        "${FUNCNAME[1]}" \
        1>&2

    # False positive: not format string(ShellCheck #1028)
    # shellcheck disable=SC2059
    printf \
        "${printf_arguments[@]}" \
        1>&2
}

print_info(){
    local -a printf_arguments=("${@}")

    if test "${#printf_arguments[@]}" -eq 0; then
        print_fatal 'This function should have at least 1 argument.\n'
        exit 1
    fi

    printf_with_color \
        green \
        'Info: '

    # False positive: not format string(ShellCheck #1028)
    # shellcheck disable=SC2059
    printf_with_color \
        green \
        "${printf_arguments[@]}"
}

print_warning(){
    local -a printf_arguments=("${@}")

    if test "${#printf_arguments[@]}" -eq 0; then
        print_fatal 'This function should have at least 1 argument.\n'
        exit 1
    fi

    printf_with_color \
        yellow \
        'Warning: ' \
        1>&2

    # False positive: not format string(ShellCheck #1028)
    # shellcheck disable=SC2059
    printf_with_color \
        yellow \
        "${printf_arguments[@]}" \
        1>&2
}

print_error(){
    local -a printf_arguments=("${@}")

    if test "${#printf_arguments[@]}" -eq 0; then
        print_fatal 'This function should have at least 1 argument.\n'
        exit 1
    fi

    printf_with_color \
        red \
        'ERROR: ' \
        1>&2

    # False positive: not format string(ShellCheck #1028)
    # shellcheck disable=SC2059
    printf_with_color \
        red \
        "${printf_arguments[@]}" \
        1>&2
}

print_debug(){
    local -a printf_arguments=("${@}")

    if test "${#printf_arguments[@]}" -eq 0; then
        print_fatal 'This function should have at least 1 argument.\n'
        exit 1
    fi

    printf \
        '%s: DEBUG: ' \
        "${FUNCNAME[1]}" \
        1>&2

    # False positive: not format string(ShellCheck #1028)
    # shellcheck disable=SC2059
    printf \
        "${printf_arguments[@]}" \
        1>&2
}

shift_array(){
    check_function_parameters_quantity 1 "${#}"

    local -n array_ref="${1}"

    if [ "${#array_ref[@]}" -eq 0 ]; then
        print_fatal \
            'array is empty!\n'
        exit 1
    fi

    # Unset the 1st element
    unset 'array_ref[0]'

    # Repack array if element still available in array
    if [ "${#array_ref[@]}" -ne 0 ]; then
        array_ref=("${array_ref[@]}")
    fi

    return 0
}

util_is_parameter_set_and_not_empty(){
    check_function_parameters_quantity 1 $#

    local parameter_name="${1}"

    if [ ! -v "${parameter_name}" ]; then
        return 1
    else
        declare -n parameter_ref
        parameter_ref="${parameter_name}"

        if [ -z "${parameter_ref}" ]; then
            return 1
        else
            return 0
        fi
    fi
}

# Utility function to check if function parameters quantity is legal
# NOTE: non-static function parameter quantity(e.g. either 2 or 3) is not supported
check_function_parameters_quantity(){
    if [ "${#}" -ne 2 ]; then
        print_fatal \
            'Function requires %u parameters, but %u is given\n' \
            2 \
            "${#}"
        exit 1
    fi

    # The expected given quantity
    local -i expected_parameter_quantity="${1}"; shift
    # The actual given parameter quantity, simply pass "${#}" will do
    local -i given_parameter_quantity="${1}"

    if [ "${given_parameter_quantity}" -ne "${expected_parameter_quantity}" ]; then
        print_fatal \
            'Function requires %u parameters, but %u is given\n' \
            "${expected_parameter_quantity}" \
            "${given_parameter_quantity}"
        exit 1
    fi
    return 0
}

# Generate reliable and user-friendly timestamps
generate_timestamp(){
    printf \
        %s \
        "$(
            LC_TIME=C.UTF-8 \
                date \
                +%Y%m%d-%H%M%S-%A
        )"
}

# Makes debuggers' life easier - Unofficial Bash Strict Mode
# BASHDOC: Shell Builtin Commands - Modifying Shell Behavior - The Set Builtin
set \
    -o errexit \
    -o errtrace \
    -o nounset \
    -o pipefail

# Check unsupported Bash version
if test "${BASH_VERSINFO[0]}" -lt 4 \
    || { test "${BASH_VERSINFO[0]}" -eq 4 \
        && test "${BASH_VERSINFO[1]}" -lt 3;}; then
    print_error \
        'This program requires Bash >= 4.3 to function properly, refer <%s> for more info.\n' \
        https://github.com/WoeUSB/WoeUSB#dependencies
    exit 1
fi

# Check critical dependencies for WoeUSB
for critical_command in \
    basename \
    dirname \
    mktemp \
    realpath; do
    if ! command -v "${critical_command}" &> /dev/null; then
        print_fatal \
            'This program requires GNU Coreutils in the executable search path'
        exit 1
    fi
done

# Non-overridable Primitive Variables
# BASHDOC: Shell Variables » Bash Variables
# BASHDOC: Basic Shell Features » Shell Parameters » Special Parameters
if [ -v 'BASH_SOURCE[0]' ]; then
    script_path="$(realpath --strip "${BASH_SOURCE[0]}")"
    script_filename="$(basename "${script_path}")"
    script_name="${script_filename%.*}"
    script_dir="$(dirname "${script_path}")"
    program_basecommand="${0}"
    # Keep these partially unused variables declared
    # shellcheck disable=SC2034
    declare -r \
        script_path \
        script_filename \
        script_name \
        script_dir \
        program_basecommand
fi
declare -ar program_args=("${@}")

# Global Variables #
# Only set variables global when there's no other way around(like passing
# in function as a function argument), usually when the variable is directly
# or indirectly referenced by traps
#
# Even when the parameter is set global, you should pass it in as function
# argument when it's possible for better code reusability.

# Increase verboseness, provide more information when required
declare verbose=false

# Disable message coloring when set to `true`, set by --no-color
declare no_color=false

declare -ir DD_BLOCK_SIZE="((4 * 1024 * 1024))" # 4MiB
declare -ir FAT32_FILESIZE_LIMIT=4294967295 # 2^32 - 1

# NOTE: Need to pass to traps, so need to be global
declare \
    source_fs_mountpoint \
    target_fs_mountpoint \
    target_device

# Supported filesystems
# A associated array with supported filesystem's identifier as key and its description as value
declare -A ENUM_SUPPORTED_FILESYSTEMS=(
    [FS_FAT]='File Allocation Table(FAT)'
    [FS_NTFS]='New Technology File System(NTFS)'
)

trap trap_exit EXIT
trap trap_errexit ERR
trap trap_interrupt INT

declare temp_directory; temp_directory=$(
    mktemp \
        -d \
        -t \
        WoeUSB.tempdir.XXXXXX
); declare -r temp_directory

# wimlib's process ID, needed to be killed in EXIT trap
declare wimlib_imagex_pid=

init \
    "${script_name}"
