using System.Collections.Generic;
using System.Threading.Tasks;
using api_app_notes.Model.DTO;
using api_app_notes.Model.Service;
using Microsoft.AspNetCore.Mvc;

[Route("api/[controller]")]
[ApiController]
public class NotesController : ControllerBase
{
    private readonly INotesService _notesService;

    public NotesController(INotesService notesService)
    {
        _notesService = notesService;
    }

    [HttpGet("{email}")]
    public async Task<IEnumerable<NotesDTO>> GetNotes(string email)
    {
        return await _notesService.GetNotes(email);
    }

    [HttpPost]
    public async Task<IActionResult> AddNote(NotesDTO note)
    {
        var result = await _notesService.AddNote(note);
        return Ok(result);
    }

    [HttpPut]
    public async Task<IActionResult> UpdateNote(NotesDTO note)
    {
        var result = await _notesService.UpdateNote(note);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteNote(int id)
    {
        var result = await _notesService.DeleteNote(id);
        return Ok(result);
    }
}

