#!/bin/bash


PROJECTS=(
    "microservice-user-profile"
    "microservice-user"
    "microservice-registration"
    "microservice-mail"
    "microservice-apps-management"
    "jwt-issuer"
    "identity-provider"
    "authorization-server"
)

CUSTOM_DOCKER_BUILDS=(
    "kong"
    "prometheus"
)


function log_info(){
    msg="$1"
    if [ -t 1 ]; then
        echo -e "\e[34m[INFO]\e[0m: $msg"
    else
        echo "[INFO]: $msg"
    fi
}

function log_warn(){
    msg="$1"
    if [ -t 1 ]; then
        echo -e "\e[43m[WARN]\e[0m: $msg"
    else
        echo "[WARN]: $msg"
    fi
}

function log_error(){
    msg="$1"
    if [ -t 1 ]; then
        echo -e "\e[91m[ERROR]\e[0m: $msg"
    else
        echo "[ERROR]: $msg"
    fi
}


function build_image(){
    context_path="$1"
    project_name="$2"
    image_tag="$3"

    # Check if project already checked out in context path
    project_dir="$context_path/$project_name"
    log_info "Building $project_dir as $image_tag"
    if [ ! -d "$context_path" ]; then
        log_warn "Directory ${context_path} does not exit. Will be created."
        mkdir -p "${context_path}"
    fi

    if [ ! -d "$project_dir" ]; then
        git_repo_url="https://github.com/Microkubes/${project_name}.git"
        log_info "Checking out $git_repo_url"
        git clone "$git_repo_url" "$project_dir"
        if [ $? -eq 0 ]; then
            log_info "Cloned successfully"
        else
            log_error "Failed to clone repository at ${git_repo_url}"
            return 1
        fi
    fi

    log_info "Building docker image"
    curr_dir=$(pwd)
    cd "${project_dir}"
    docker build -t "$image_tag" .
    if [ $? -eq 0 ]; then
        log_info "Successfuly built docker image tag: ${image_tag} from ${project_dir}"
    else
        log_error "Failed to build docker image"
        cd "${curr_dir}"
        return 1    
    fi
    cd "${curr_dir}"
    return 0
}

function build_custom_docker_image(){
    path=$1
    image_tag=$2

    curr_dir=$(pwd)
    if [ ! -d "$path" ]; then
        log_error "Custom docker build image path $path does not exist"
        return 1
    fi
    cd "$path"
    docker build -t "$image_tag" .
    if [ $? -eq 0 ]; then
        log_info "Successfully built docker image ${image_tag} from ${path}"
    else
        log_error "Failed to build ${path}"
        cd "${curr_dir}"
        return 1
    fi
    cd "${curr_dir}"
    return 0
}

function build_custom_docker_images(){
    context_path="$1"
    tag="$2"
    if [ -z  "$tag" ]; then
        tag="latest"
    fi

    if [ ! -d "${context_path}/microkubes" ]; then
        mkdir -p "${context_path}"
        log_info "Will checkout latest version of microkubes from github.com"
        git clone "https://github.com/Microkubes/microkubes" "${context_path}/microkubes"
        if [ $? -eq 0 ];then
            log_info "Checked out successfully"
        else
            log_error "Failed to check out microkubes repository"
            return 1
        fi
    fi

    for image in ${CUSTOM_DOCKER_BUILDS[*]}
    do
        image_tag="microkubes/${image}:${tag}"
        path=$(readlink -f "${context_path}/microkubes/docker/${image}")
        log_info "Building ${image}..."
        build_custom_docker_image "${path}" "${image_tag}"
        if [ ! $? -eq 0 ]; then
            log_error "Failed to build custom image for ${image}"
            return 1
        fi
    done
    log_info "Custom images build successfully."
    return 0
}

function build_microservces(){
    context_path="$1"
    tag="$2"

    if [ -z  "$tag" ]; then
        tag="latest"
    fi

    if [ ! -d "${context_path}" ];then
        mkdir -p "${context_path}"
        if [ ! $? -eq 0 ]; then
            log_error "Failed to create target build directory"
            return 1
        fi
    fi

    for project in ${PROJECTS[*]}
    do
        log_info "Building docker image for ${project}..."
        image_tag="microkubes/${project}:${tag}"
        build_image "${context_path}" "${project}" "${image_tag}"
        if [ ! $? -eq 0 ]; then
            log_error "Failed to build ${project}"
            return 1
        fi
    done
    log_info "Microservices build successfully"
    return 0
}

context_path="$1"
tag="$2"

if [ -z "$context_path" ];then
    context_path=$(readlink -f .)
fi

if [ -z "$tag" ]; then
    tag="latest"
fi

log_info "Bulding Microkubes images in: ${context_path}"
log_info "Tag: ${tag}"

echo ""

log_info "Building custom images..."
build_custom_docker_images "${context_path}" "${tag}"
if [ ! $? -eq 0 ];then
    log_error "Build failed"
    exit 1
fi

log_info "Building microservices..."
build_microservces "${context_path}" "${tag}"
if [ ! $? -eq 0 ];then
    log_error "Build failed"
    exit 1
fi


