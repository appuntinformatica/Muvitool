fineUploaderMessages = {
    typeError: "{file} has an invalid extension. Valid extension(s): {extensions}.",
    sizeError: "{file} is too large, maximum file size is {sizeLimit}.",
    minSizeError: "{file} is too small, minimum file size is {minSizeLimit}.",
    emptyError: "{file} is empty, please select files again without it.",
    noFilesError: "No files to upload.",
    tooManyItemsError: "Too many items ({netItems}) would be uploaded.  Item limit is {itemLimit}.",
    maxHeightImageError: "Image is too tall.",
    maxWidthImageError: "Image is too wide.",
    minHeightImageError: "Image is not tall enough.",
    minWidthImageError: "Image is not wide enough.",
    retryFailTooManyItems: "Retry failed - you have reached your file limit.",
    onLeave: "The files are being uploaded, if you leave now the upload will be canceled.",
    unsupportedBrowserIos8Safari: "Unrecoverable error - this browser does not permit file uploading of any kind due to serious bugs in iOS8 Safari.  Please use iOS8 Chrome until Apple fixes these issues."
};
fineUploaderStatus = {
    SUBMITTING: "submitting",
    SUBMITTED: "submitted",
    REJECTED: "rejected",
    QUEUED: "queued",
    CANCELED: "canceled",
    PAUSED: "paused",
    UPLOADING: "uploading",
    UPLOAD_RETRYING: "retrying upload",
    UPLOAD_SUCCESSFUL: "upload successful",
    UPLOAD_FAILED: "upload failed",
    DELETE_FAILED: "delete failed",
    DELETING: "deleting",
    DELETED: "deleted"
};
fineUploaderText = {
    formatProgress: "{percent}% of {total_size}",
    failUpload: "Upload failed",
    waitingForResponse: "Processing...",
    paused: "Paused"
};