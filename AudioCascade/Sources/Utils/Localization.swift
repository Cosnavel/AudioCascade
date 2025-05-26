import Foundation

struct Localization {
    static let shared = Localization()

    private let translations: [String: [String: String]] = [
        "en": [
            // App Name
            "app_name": "AudioCascade",
            "app_tagline": "Smart Audio Device Manager",

            // Tabs
            "tab_input": "Input",
            "tab_output": "Output",

            // Search
            "search_placeholder": "Search devices...",

            // Device Status
            "status_disabled": "Disabled",
            "status_not_connected": "Not connected • Last seen %@",
            "status_active": "Currently active",
            "status_ready": "Ready",
            "status_disconnected": "Device is disconnected",

            // Empty State
            "empty_input_title": "No Input Devices",
            "empty_output_title": "No Output Devices",
            "empty_subtitle": "Connect an audio device to see it here",

            // Context Menu
            "menu_set_default": "Set as Default",
            "menu_disable": "Disable Device",
            "menu_enable": "Enable Device",

            // Settings
            "settings_title": "Settings",
            "settings_general": "General",
            "settings_audio": "Audio Management",
            "settings_about": "About",

            // Settings Options
            "settings_start_login": "Start at Login",
            "settings_show_dock": "Show in Dock",
            "settings_check_interval": "Check Interval",
            "settings_reset_priorities": "Reset All Priorities",
            "settings_clear_disconnected": "Clear Disconnected Devices",
            "settings_version": "Version",
            "settings_github": "GitHub Repository",
            "settings_report_issue": "Report an Issue",

            // Alerts
            "alert_reset_title": "Reset Priorities?",
            "alert_reset_message": "This will reset all device priorities to their default order.",
            "alert_clear_title": "Clear Disconnected Devices?",
            "alert_clear_message": "This will remove all disconnected devices from your saved list.",
            "alert_cancel": "Cancel",
            "alert_reset": "Reset",
            "alert_clear": "Clear"
        ],
        "de": [
            // App Name
            "app_name": "AudioCascade",
            "app_tagline": "Intelligente Audio-Geräteverwaltung",

            // Tabs
            "tab_input": "Eingabe",
            "tab_output": "Ausgabe",

            // Search
            "search_placeholder": "Geräte suchen...",

            // Device Status
            "status_disabled": "Deaktiviert",
            "status_not_connected": "Nicht verbunden • Zuletzt gesehen %@",
            "status_active": "Aktuell aktiv",
            "status_ready": "Bereit",
            "status_disconnected": "Gerät ist getrennt",

            // Empty State
            "empty_input_title": "Keine Eingabegeräte",
            "empty_output_title": "Keine Ausgabegeräte",
            "empty_subtitle": "Verbinde ein Audiogerät, um es hier zu sehen",

            // Context Menu
            "menu_set_default": "Als Standard festlegen",
            "menu_disable": "Gerät deaktivieren",
            "menu_enable": "Gerät aktivieren",

            // Settings
            "settings_title": "Einstellungen",
            "settings_general": "Allgemein",
            "settings_audio": "Audio-Verwaltung",
            "settings_about": "Über",

            // Settings Options
            "settings_start_login": "Bei Anmeldung starten",
            "settings_show_dock": "Im Dock anzeigen",
            "settings_check_interval": "Prüfintervall",
            "settings_reset_priorities": "Alle Prioritäten zurücksetzen",
            "settings_clear_disconnected": "Getrennte Geräte entfernen",
            "settings_version": "Version",
            "settings_github": "GitHub Repository",
            "settings_report_issue": "Problem melden",

            // Alerts
            "alert_reset_title": "Prioritäten zurücksetzen?",
            "alert_reset_message": "Dies setzt alle Geräteprioritäten auf ihre Standardreihenfolge zurück.",
            "alert_clear_title": "Getrennte Geräte entfernen?",
            "alert_clear_message": "Dies entfernt alle getrennten Geräte aus deiner gespeicherten Liste.",
            "alert_cancel": "Abbrechen",
            "alert_reset": "Zurücksetzen",
            "alert_clear": "Entfernen"
        ],
        "fr": [
            // App Name
            "app_name": "AudioCascade",
            "app_tagline": "Gestionnaire Audio Intelligent",

            // Tabs
            "tab_input": "Entrée",
            "tab_output": "Sortie",

            // Search
            "search_placeholder": "Rechercher des appareils...",

            // Device Status
            "status_disabled": "Désactivé",
            "status_not_connected": "Non connecté • Vu pour la dernière fois %@",
            "status_active": "Actuellement actif",
            "status_ready": "Prêt",
            "status_disconnected": "L'appareil est déconnecté",

            // Empty State
            "empty_input_title": "Aucun Périphérique d'Entrée",
            "empty_output_title": "Aucun Périphérique de Sortie",
            "empty_subtitle": "Connectez un périphérique audio pour le voir ici",

            // Context Menu
            "menu_set_default": "Définir par Défaut",
            "menu_disable": "Désactiver l'Appareil",
            "menu_enable": "Activer l'Appareil",

            // Settings
            "settings_title": "Paramètres",
            "settings_general": "Général",
            "settings_audio": "Gestion Audio",
            "settings_about": "À propos",

            // Settings Options
            "settings_start_login": "Lancer au Démarrage",
            "settings_show_dock": "Afficher dans le Dock",
            "settings_check_interval": "Intervalle de Vérification",
            "settings_reset_priorities": "Réinitialiser Toutes les Priorités",
            "settings_clear_disconnected": "Effacer les Appareils Déconnectés",
            "settings_version": "Version",
            "settings_github": "Dépôt GitHub",
            "settings_report_issue": "Signaler un Problème",

            // Alerts
            "alert_reset_title": "Réinitialiser les Priorités?",
            "alert_reset_message": "Cela réinitialisera toutes les priorités des appareils à leur ordre par défaut.",
            "alert_clear_title": "Effacer les Appareils Déconnectés?",
            "alert_clear_message": "Cela supprimera tous les appareils déconnectés de votre liste enregistrée.",
            "alert_cancel": "Annuler",
            "alert_reset": "Réinitialiser",
            "alert_clear": "Effacer"
        ]
    ]

    private var currentLanguage: String {
        let preferredLanguages = Locale.preferredLanguages
        for language in preferredLanguages {
            let languageCode = String(language.prefix(2))
            if translations[languageCode] != nil {
                return languageCode
            }
        }
        return "en"
    }

    func localized(_ key: String) -> String {
        return translations[currentLanguage]?[key] ?? translations["en"]?[key] ?? key
    }

    func localized(_ key: String, with arguments: CVarArg...) -> String {
        let format = localized(key)
        return String(format: format, arguments: arguments)
    }
}

// Update the String extension to use our Localization struct
extension String {
    var localized: String {
        return Localization.shared.localized(self)
    }

    func localized(with arguments: CVarArg...) -> String {
        return Localization.shared.localized(self, with: arguments)
    }
}
