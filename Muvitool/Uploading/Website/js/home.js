var datatable;
var i18nDT;

$(document).ready(function() {
    var fineUploaderMessages;
    var fineUploaderStatus;
    var fineUploaderText;
    $.get( '/fine-uploader/i18n/' + lang + '.js', function( data ) {
        eval(data);
        $.get( '/fine-uploader/i18n/template.' + lang + '.html', function( data ) {
            $('#qq-template').html( data );
            var fineUploader = new qq.FineUploader({
                element: document.getElementById("fine-uploader"),
                template: 'qq-template',                
                request: {
                    endpoint: '/upload',
                    inputName: 'files[]',
                    params: { path: '/'}
                },
                thumbnails: {
                    placeholders: {
                        waitingPath: '/fine-uploader/placeholders/waiting-generic.png',
                        notAvailablePath: '/fine-uploader/placeholders/not_available-generic.png'
                    }
                },
                validation: {
                    allowedExtensions: ['mp3', 'm4a', 'mp4', 'MOV', 'avi', 'wav' ],
                    /* itemLimit: 10, */
                    sizeLimit: 1073741824 // 1GB = 1024 * 1024 * 1024 bytes
                },
                callbacks: {
                    onError: function(id, name, errorReason, xhrOrXdr) {
                        alert(qq.format("Error on file number {} - {}.  Reason: {}", id, name, errorReason));
                    },
                    onAllComplete: function (successed, failed) {
                        $.ajax({ url: 'reloadData', type: 'UPDATE', dataType: 'json' }).always(function() {
                            datatable.ajax.reload();
                        });
                    }
                },
                messages: fineUploaderMessages,
                text: fineUploaderText
            });
            fineUploader.status = fineUploaderStatus;
        });        
    });
                  
    $.get( '/DataTables/i18n/i18nDT.' + lang + '.js', function( data ) {
        i18nDT = eval(data);
    
        datatable = $('#datatable').DataTable({
            'ajax' : '/list',
            'serverSide' : true,
            'language': {
                "url": "/DataTables/i18n/DataTables." + lang + ".json"
            },
            columns : [ {
                data  : 'filename',
                title : i18nDT.columns['filename']
            }, {
                data  : 'filesize',
                title : i18nDT.columns['filesize']
            }, {
                data  : 'datetime',
                title : i18nDT.columns['datetime']
            }, {
                data  : 'actions',
                title : i18nDT.columns['download'],
                render: function (data, type, row) {
                    return "<button type='button' class='btn btn-default btn-sm' onclick='download(\"" + data + "\")'><span class='glyphicon glyphicon-cloud-download' aria-hidden='true'></span></button>"
                }
            }]
        });    
    });
});



function download(path) {
    window.location = "download?path=" + encodeURIComponent(path)
}
function deleteFile(path, refreshCallback) {
    if ( confirm(i18nDT.messages['confirm_delete']) ) {
        $.ajax({
               url: 'delete',
               type: 'POST',
               data: {path: path},
               dataType: 'json'
               }).always(datatable.ajax.reload());
    }
}
