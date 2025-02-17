$('[data-title="outer_ancestors"]').dropdown({
  placeholder: false,
  onChange: function(value, text, $selectedItem){
    var search_url = new URL('admin/members/options', location.origin);
    if (value) {
      search_url.searchParams.set('department_id', this.value);
    }
    search_url.searchParams.set('as', this.dataset['as']);
    search_url.searchParams.set('method', this.dataset['method']);
    search_url.searchParams.set('outer', this.dataset['outer']);
    if (this.dataset['index']) {
      search_url.searchParams.set('index', this.dataset['index']);
    }

    Rails.ajax({url: search_url, type: 'GET', dataType: 'script'});
  }
});
$('[data-title="job_title_id"]').dropdown();
