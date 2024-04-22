using api_app_notes.Model.DTO;

namespace api_app_notes.Model.Service
{
    public interface INotesService
    {
        Task<IEnumerable<NotesDTO>> GetNotes(string email);
        Task<bool> AddNote(NotesDTO note);
        Task<bool> UpdateNote(NotesDTO note);
        Task<bool> DeleteNote(int id);
    }
}
