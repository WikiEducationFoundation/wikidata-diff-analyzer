class Total
    def self.accumulate_totals(diff_data, total)
        total[:claims_added] += diff_data[:added_claims]
        total[:claims_removed] += diff_data[:removed_claims]
        total[:claims_changed] += diff_data[:changed_claims]
        total[:qualifiers_added] += diff_data[:added_qualifiers]
        total[:qualifiers_removed] += diff_data[:removed_qualifiers]
        total[:qualifiers_changed] += diff_data[:changed_qualifiers]
        total[:references_added] += diff_data[:added_references]
        total[:references_removed] += diff_data[:removed_references]
        total[:references_changed] += diff_data[:changed_references]
        total[:aliases_added] += diff_data[:added_aliases]
        total[:aliases_removed] += diff_data[:removed_aliases]
        total[:aliases_changed] += diff_data[:changed_aliases]
        total[:labels_added] += diff_data[:added_labels]
        total[:labels_removed] += diff_data[:removed_labels]
        total[:labels_changed] += diff_data[:changed_labels]
        total[:descriptions_added] += diff_data[:added_descriptions]
        total[:descriptions_removed] += diff_data[:removed_descriptions]
        total[:descriptions_changed] += diff_data[:changed_descriptions]
        total[:sitelinks_added] += diff_data[:added_sitelinks]
        total[:sitelinks_removed] += diff_data[:removed_sitelinks]
        total[:sitelinks_changed] += diff_data[:changed_sitelinks]
    end
end