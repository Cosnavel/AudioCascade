import Foundation

struct Localization {
    static let strings: [String: [String: String]] = [
        // App
        "app_name": [
            "en": "AudioCascade",
            "de": "AudioCascade",
            "fr": "AudioCascade"
        ],
        "app_tagline": [
            "en": "Smart Audio Device Management",
            "de": "Intelligente Audiogeräteverwaltung",
            "fr": "Gestion intelligente des périphériques audio"
        ],

        // Tabs
        "tab_input": [
            "en": "Input",
            "de": "Eingabe",
            "fr": "Entrée"
        ],
        "tab_output": [
            "en": "Output",
            "de": "Ausgabe",
            "fr": "Sortie"
        ],

        // Device Status
        "status_active": [
            "en": "Active",
            "de": "Aktiv",
            "fr": "Actif"
        ],
        "status_ready": [
            "en": "Ready",
            "de": "Bereit",
            "fr": "Prêt"
        ],
        "status_disabled": [
            "en": "Disabled",
            "de": "Deaktiviert",
            "fr": "Désactivé"
        ],
        "status_not_connected": [
            "en": "Not connected • Last seen %@",
            "de": "Nicht verbunden • Zuletzt gesehen %@",
            "fr": "Non connecté • Vu pour la dernière fois %@"
        ],
        "status_disconnected": [
            "en": "Device is currently disconnected",
            "de": "Gerät ist derzeit nicht verbunden",
            "fr": "L'appareil est actuellement déconnecté"
        ],

        // Search
        "search_placeholder": [
            "en": "Search devices...",
            "de": "Geräte suchen...",
            "fr": "Rechercher des appareils..."
        ],

        // Device List
        "no_devices": [
            "en": "No devices found",
            "de": "Keine Geräte gefunden",
            "fr": "Aucun appareil trouvé"
        ],
        "priority": [
            "en": "Priority %d",
            "de": "Priorität %d",
            "fr": "Priorité %d"
        ],

        // Context Menu
        "menu_set_default": [
            "en": "Set as Default",
            "de": "Als Standard festlegen",
            "fr": "Définir par défaut"
        ],
        "menu_enable": [
            "en": "Enable",
            "de": "Aktivieren",
            "fr": "Activer"
        ],
        "menu_disable": [
            "en": "Disable",
            "de": "Deaktivieren",
            "fr": "Désactiver"
        ],
        "menu_edit_shortcut": [
            "en": "Edit Keyboard Shortcut",
            "de": "Tastenkürzel bearbeiten",
            "fr": "Modifier le raccourci clavier"
        ],
        "menu_clear_shortcut": [
            "en": "Clear Keyboard Shortcut",
            "de": "Tastenkürzel löschen",
            "fr": "Effacer le raccourci clavier"
        ],

        // Settings
        "settings_title": [
            "en": "Settings",
            "de": "Einstellungen",
            "fr": "Paramètres"
        ],
        "settings_general": [
            "en": "General",
            "de": "Allgemein",
            "fr": "Général"
        ],
        "settings_start_login": [
            "en": "Start at Login",
            "de": "Bei Anmeldung starten",
            "fr": "Lancer au démarrage"
        ],
        "settings_show_dock": [
            "en": "Show in Dock",
            "de": "Im Dock anzeigen",
            "fr": "Afficher dans le Dock"
        ],
        "settings_check_interval": [
            "en": "Check Interval",
            "de": "Prüfintervall",
            "fr": "Intervalle de vérification"
        ],
        "settings_seconds": [
            "en": "%g seconds",
            "de": "%g Sekunden",
            "fr": "%g secondes"
        ],
        "settings_device_management": [
            "en": "Device Management",
            "de": "Geräteverwaltung",
            "fr": "Gestion des appareils"
        ],
        "settings_reset_priorities": [
            "en": "Reset All Priorities",
            "de": "Alle Prioritäten zurücksetzen",
            "fr": "Réinitialiser toutes les priorités"
        ],
        "settings_clear_disconnected": [
            "en": "Clear Disconnected Devices",
            "de": "Getrennte Geräte entfernen",
            "fr": "Effacer les appareils déconnectés"
        ],
        "settings_about": [
            "en": "About",
            "de": "Über",
            "fr": "À propos"
        ],
        "settings_version": [
            "en": "Version %@",
            "de": "Version %@",
            "fr": "Version %@"
        ],
        "settings_developer": [
            "en": "Developed by %@",
            "de": "Entwickelt von %@",
            "fr": "Développé par %@"
        ],
        "settings_quit": [
            "en": "Quit AudioCascade",
            "de": "AudioCascade beenden",
            "fr": "Quitter AudioCascade"
        ],

        // Confirmations
        "confirm_reset": [
            "en": "Reset complete",
            "de": "Zurücksetzen abgeschlossen",
            "fr": "Réinitialisation terminée"
        ],
        "confirm_cleared": [
            "en": "Cleared %d devices",
            "de": "%d Geräte entfernt",
            "fr": "%d appareils effacés"
        ],

        // Shortcut
        "shortcut_title": [
            "en": "Keyboard Shortcut",
            "de": "Tastaturkürzel",
            "fr": "Raccourci clavier"
        ],
        "shortcut_edit": [
            "en": "Edit Shortcut",
            "de": "Tastenkürzel bearbeiten",
            "fr": "Modifier le raccourci"
        ],
        "shortcut_help": [
            "en": "Press any key combination with modifiers (⌘, ⇧, ⌥, ⌃)",
            "de": "Drücke eine Tastenkombination mit Modifikatoren (⌘, ⇧, ⌥, ⌃)",
            "fr": "Appuyez sur une combinaison de touches avec modificateurs (⌘, ⇧, ⌥, ⌃)"
        ],

        // Manual Mode
        "manual_mode_active": [
            "en": "Manual Mode Active - Automatic switching paused",
            "de": "Manueller Modus aktiv - Automatisches Umschalten pausiert",
            "fr": "Mode manuel actif - Commutation automatique en pause"
        ],
        "manual_mode_disable": [
            "en": "Resume Auto",
            "de": "Auto fortsetzen",
            "fr": "Reprendre auto"
        ],

        // Permissions
        "permission_title": [
            "en": "Enable Keyboard Shortcuts",
            "de": "Tastaturkürzel aktivieren",
            "fr": "Activer les raccourcis clavier"
        ],
        "permission_description": [
            "en": "AudioCascade needs accessibility permissions to use global keyboard shortcuts for instant device switching.",
            "de": "AudioCascade benötigt Bedienungshilfen-Berechtigungen für globale Tastaturkürzel zum sofortigen Gerätewechsel.",
            "fr": "AudioCascade a besoin des autorisations d'accessibilité pour utiliser les raccourcis clavier globaux."
        ],
        "permission_feature_shortcuts": [
            "en": "Quick Switch",
            "de": "Schnellwechsel",
            "fr": "Changement rapide"
        ],
        "permission_feature_global": [
            "en": "Works Everywhere",
            "de": "Überall verfügbar",
            "fr": "Fonctionne partout"
        ],
        "permission_feature_secure": [
            "en": "Privacy First",
            "de": "Datenschutz zuerst",
            "fr": "Confidentialité"
        ],
        "permission_instructions": [
            "en": "How to enable:",
            "de": "So aktivieren Sie:",
            "fr": "Comment activer:"
        ],
        "permission_step1": [
            "en": "Click \"Open Settings\" below",
            "de": "Klicke unten auf \"Einstellungen öffnen\"",
            "fr": "Cliquez sur \"Ouvrir les paramètres\""
        ],
        "permission_step2": [
            "en": "Find AudioCascade in the list",
            "de": "Finde AudioCascade in der Liste",
            "fr": "Trouvez AudioCascade dans la liste"
        ],
        "permission_step3": [
            "en": "Toggle the switch to enable",
            "de": "Schalter zum Aktivieren umlegen",
            "fr": "Activez l'interrupteur"
        ],
        "permission_later": [
            "en": "Maybe Later",
            "de": "Später",
            "fr": "Plus tard"
        ],
        "permission_open_settings": [
            "en": "Open Settings",
            "de": "Einstellungen öffnen",
            "fr": "Ouvrir les paramètres"
        ],

        // Common
        "done": [
            "en": "Done",
            "de": "Fertig",
            "fr": "Terminé"
        ]
    ]
}

extension String {
    var localized: String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        let supportedLanguage = ["en", "de", "fr"].contains(languageCode) ? languageCode : "en"

        return Localization.strings[self]?[supportedLanguage] ?? self
    }

    func localized(with args: CVarArg...) -> String {
        let format = self.localized
        return String(format: format, arguments: args)
    }
}
