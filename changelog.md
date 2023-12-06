# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Improvement EFS module with new features, like aws_efs_create_mount_target, aws_efs_vol_encrypted, aws_efs_kms_key_id, aws_efs_performance_mode, aws_efs_throughput_mode, aws_efs_throughput_speed, aws_efs_allowed_security_groups and aws_efs_ingress_allow_all.
- EFS module now exports EFS FS ID, EFS Replica FS ID and EFS SG ID.

### Changed
- Importing EFS volume now will try to create mount targets as default. Toggle aws_efs_create_mount_target to false to avoid the creation of new ones. Security groups should allow incoming traffic.

### Removed
- EFS module lost aws_efs_vpc_id and aws_efs_subnet_ids in favor of using the aws_vpc_id and aws_vpc_subnet_id. 

## [1.0.0] - 2023-11-13

### Added
- Lot's of improvements. Check the [v1-changes](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/blob/commons/v1-changes.md) doc.