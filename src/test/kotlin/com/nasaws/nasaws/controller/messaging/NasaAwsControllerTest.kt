package com.nasaws.nasaws.controller.messaging

import com.nasaws.nasaws.service.messaging.NasaAwsService
import org.junit.jupiter.api.Test
import org.mockito.Mockito.doNothing
import org.mockito.Mockito.`when`
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.post

@WebMvcTest(NasaAwsController::class)
class NasaAwsControllerTest {

    @Autowired
    lateinit var mockMvc: MockMvc

    @MockBean
    lateinit var nasaAwsService: NasaAwsService

    @Test
    fun `checkServiceIsWorking returns expected string`() {
        mockMvc.get("/test/v1")
            .andExpect {
                status { isOk() }
                content { string("Testing Controller from API") }
            }
    }

    @Test
    fun `getNasaImageOfTheDay returns service response`() {
        val expected = mapOf("image" to "url", "title" to "NASA IOTD")
        `when`(nasaAwsService.getNasaIOD(null)).thenReturn(expected)

        mockMvc.get("/test/v1/nasa/iotd")
            .andExpect {
                status { isOk() }
                content { json("""{"image":"url","title":"NASA IOTD"}""") }
            }
    }

    @Test
    fun `getNasaImageOfTheDayAndPostToSnsTopic returns CREATED`() {
        doNothing().`when`(nasaAwsService).postNasaImageOfDayMessageToSnsTopic(null)

        mockMvc.post("/test/v1/nasa/iotd/send-message")
            .andExpect {
                status { isCreated() }
            }
    }
}