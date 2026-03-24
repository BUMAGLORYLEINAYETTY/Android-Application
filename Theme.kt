package org.example.gui

import androidx.compose.material3.darkColorScheme
import androidx.compose.ui.graphics.Color

object AppColors {
    // --- Palette "Améthyste Royale" (Électrique sur Noir) ---
    val Primary        = Color(0xFFA855F7) // Violet vibrant
    val Accent         = Color(0xFFFFD700) // Or pur (pour faire ressortir les moyennes)
    val Danger         = Color(0xFFFF3366) // Rose-rouge néon
    val Warning        = Color(0xFFFB923C) // Orange brûlé
    val Success        = Color(0xFF2DD4BF) // Turquoise émeraude

    // --- Surfaces "Obsidian" (Noir profond organique) ---
    // Un noir avec une pointe de violet très subtile pour la profondeur
    val Surface        = Color(0xFF0C0A0F)
    val SurfaceVariant = Color(0xFF17121C) // Pour la barre du haut
    val CardBg         = Color(0xFF1F1A24) // Pour les cartes et lignes du tableau
    val Border         = Color(0xFF2D2438) // Bordure violette très sombre

    // --- Typographie ---
    val TextPrimary    = Color(0xFFE9D5FF) // Lavande très clair (mieux que le blanc pur)
    val TextSecondary  = Color(0xFF9489A2) // Gris lavande

    // --- Palette des Grades (Nouveau dégradé "Synthwave") ---
    private val gradeMap = mapOf(
        "A+" to Color(0xFF2DD4BF), // Émeraude
        "A"  to Color(0xFF4ADE80), // Vert menthe
        "B+" to Color(0xFF38BDF8), // Bleu ciel
        "B"  to Color(0xFF818CF8), // Indigo
        "C+" to Color(0xFFA855F7), // Violet (Primary)
        "C"  to Color(0xFFC084FC), // Mauve
        "D+" to Color(0xFFFBBF24), // Ambre
        "D"  to Color(0xFFFB923C), // Orange
        "F"  to Color(0xFFFF3366)  // Danger
    )

    fun forGrade(letter: String): Color = gradeMap[letter] ?: TextSecondary

    fun forScore(score: Double): Color = when {
        score >= 75 -> Success
        score >= 60 -> Primary
        score >= 45 -> Warning
        else -> Danger
    }

    fun forFormat(label: String): Color = when {
        label.contains("xlsx", true) -> Color(0xFF22C55E)
        label.contains("pdf",  true) -> Color(0xFFEF4444)
        else                         -> Accent
    }

    val colorScheme = darkColorScheme(
        primary          = Primary,
        secondary        = Accent,
        surface          = Surface,
        onSurface        = TextPrimary,
        surfaceVariant   = SurfaceVariant,
        onSurfaceVariant = TextSecondary,
        error            = Danger,
        outline          = Border
    )
}