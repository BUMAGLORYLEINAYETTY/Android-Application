import org.jetbrains.compose.desktop.application.dsl.TargetFormat

plugins {
    kotlin("jvm")                             version "2.1.21"
    id("org.jetbrains.compose")               version "1.8.1"
    id("org.jetbrains.kotlin.plugin.compose") version "2.1.21"
}

group   = "com.gradecalc"
version = "1.0.0"

kotlin {
    // FIX : utiliser JDK 17
    jvmToolchain(17)
}

tasks.withType<JavaCompile>().configureEach {
    // FIX : cohérence avec JDK 17
    sourceCompatibility = "17"
    targetCompatibility = "17"
}

repositories {
    mavenCentral()
    google()
    maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")
}

dependencies {
    // UI Desktop
    implementation(compose.desktop.currentOs)
    implementation(compose.material3)
    implementation(compose.materialIconsExtended)

    // Excel
    implementation("org.apache.poi:poi-ooxml:5.4.1")

    // PDF
    implementation("com.itextpdf:itextpdf:5.5.13.3")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-swing:1.7.3")

    // Logging
    implementation("org.slf4j:slf4j-simple:2.0.16")
}

compose.desktop {
    application {
        mainClass = "com.gradecalc.MainKt"

        nativeDistributions {
            targetFormats(TargetFormat.Msi)
            packageName    = "GradeCalcPro"
            packageVersion = "1.0.0"
            description    = "Student Grade Calculator"
            vendor         = "YourName"

            windows {
                menuGroup   = "GradeCalc Pro"
                upgradeUuid = "3F9A1C2D-4B5E-6F7A-8B9C-0D1E2F3A4B5C"
                shortcut    = true
            }
        }
    }
}