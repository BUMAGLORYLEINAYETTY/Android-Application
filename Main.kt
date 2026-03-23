package org.example

import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import androidx.compose.ui.window.rememberWindowState
import org.example.gui.AppRoot
import org.example.gui.AppViewModel

fun main() {
    // AppViewModel créé avant application — évite les problèmes de scope Compose
    val viewModel = AppViewModel()

    application {
        Window(
            onCloseRequest = {
                viewModel.dispose()
                exitApplication()
            },
            title = " Student Grade Calculator ",
            state = rememberWindowState(width = 1200.dp, height = 800.dp)
        ) {
            AppRoot(viewModel)
        }
    }
}
